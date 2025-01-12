# Connet to available security groups from AWS
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnet" {
    filter {
      name = "vpc-id"
      values = [data.aws_vpc.default_vpc.id]
    }
}

data "aws_security_group" "application_group" {
  name = "application_group"
}

resource "aws_security_group" "lb_group" {
  name = "lb_group"
}

# Ingress rule for the security group -> allow incoming traffic on port 8080
resource "aws_security_group_rule" "allow_http_reqs" {
  type = "ingress"
  security_group_id = data.aws_security_group.application_group.id
  from_port = var.port
  to_port = var.port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Load Balancer
resource "aws_lb" "load_balancer" {
  name = "project-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default_subnet.ids
  security_groups = [aws_security_group.lb_group.id]
}

# Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = var.lb_port
  protocol = "HTTP"

  # Default action -> 404 Page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Looks like you're lost! (On Internet ;) "
      status_code = "404"
    }
  }
}

# Target Group for the Load Balancer -> Health Check
resource "aws_lb_target_group" "app_target_group" {
  name = "app-target-group"
  port = var.port
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = data.aws_vpc.default_vpc.id
  
  # Health Check
  health_check {
    path = "/"
    protocol = "HTTP"
    port = var.port
    matcher = "200"
    interval = 10 # Interval between health checks
    timeout = 5 # Timeout for health check
    healthy_threshold = 2 # Number of consecutive successful health checks
    unhealthy_threshold = 2 # Number of consecutive failed health checks
  }
}

# Load Balancer attachment for all Kube Nodes
resource "aws_lb_target_group_attachment" "kube_nodes_attachment" {
  count = length(aws_instance.kube-nodes)
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id = aws_instance.kube-nodes[count.index].id
  port = var.port
}

# Listener Rule
resource "aws_lb_listener_rule" "app_instances" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority = 100 # Priority of the rule -> Lower the number, higher the priority
  condition {
    path_pattern {
      values = ["*"] # All paths so access, like http://<lb-dns-name>/* 
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Ingress rule for load balancer -> allow incoming traffic on port 80
resource "aws_security_group_rule" "lb_incoming_req" {
  type = "ingress"
  security_group_id = aws_security_group.lb_group.id
  from_port = var.lb_port
  to_port = var.lb_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Egress rule for load balancer -> allow outgoing traffic on all ports
resource "aws_security_group_rule" "lb_outgoing_req" {
  type = "egress"
  security_group_id = aws_security_group.lb_group.id
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}