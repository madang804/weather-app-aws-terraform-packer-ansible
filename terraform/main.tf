#######
# Vpc #
#######

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

###########
# Subnets #
###########

resource "aws_subnet" "subnet" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.prefix}-subnet${count.index + 1}"
  }
}

####################
# Internet Gateway #
####################

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

################
# Route Tables #
################

resource "aws_route_table" "route_table" {
  count  = length(var.subnet_cidrs)
  vpc_id = aws_vpc.vpc.id

  # Default local route for VPC cidr is automatically added by AWS
  # and enables communication between all subnets in the VPC.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.prefix}-route-table${count.index + 1}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.subnet_cidrs)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table[count.index].id
}

###################
# Security Groups #
###################

resource "aws_security_group" "load_balancer_security_group" {
  name   = "${var.prefix}-load-balancer-security-group"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-load-balancer-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_ingress" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_egress" {
  security_group_id = aws_security_group.load_balancer_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_security_group" "ec2_instance_security_group" {
  name   = "${var.prefix}-ec2-instance-security-group"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-ec2-instance-security-group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_instance_ingress" {
  security_group_id            = aws_security_group.ec2_instance_security_group.id
  referenced_security_group_id = aws_security_group.load_balancer_security_group.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "ec2_instance_egress" {
  security_group_id = aws_security_group.ec2_instance_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

################
# EC2 Instance #
################

data "aws_ami" "packer_created_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.packer_created_ami]
  }
}

resource "aws_launch_template" "ec2_launch_template" {
  name          = "${var.prefix}-ec2-launch-template"
  image_id      = data.aws_ami.packer_created_ami.id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.ec2_instance_security_group.id]
  }
}

#################
# Load Balancer #
#################

resource "aws_lb" "internet_facing_load_balancer" {
  name               = "${var.prefix}-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = aws_subnet.subnet[*].id

  tags = {
    Name = "${var.prefix}-load-balancer"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "${var.prefix}-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port" # "traffic-port" match the port of the target group
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.internet_facing_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

################
# Auto Scaling #
################

resource "aws_autoscaling_group" "autoscaling_group" {
  name                = "${var.prefix}-autoscaling-group"
  vpc_zone_identifier = aws_subnet.subnet[*].id
  target_group_arns   = [aws_lb_target_group.target_group.arn]
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}-autoscaling-instance"
    propagate_at_launch = true
  }
}
