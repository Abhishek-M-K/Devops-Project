# EC2 Instances - Ubuntu 20.04 LTS

# resource "aws_instance" "app1" {
#   ami = var.ami
#   instance_type = var.instance_type
#   security_groups = [data.aws_security_group.application_group.name]
#   user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello All, Abhishek here! Devops if fun !!!" > index.html
#                 python3 -m http.server 8080 &
#                 EOF
# }

# resource "aws_instance" "app2" {
#   ami = var.ami
#   instance_type = var.instance_type
#   security_groups = [data.aws_security_group.application_group.name]
#   user_data = <<-EOF
#                     #!/bin/bash
#                     echo "Hello All, Abhishek here! Let's how fun Devops is > <" > index.html
#                     python3 -m http.server 8080 &
#                     EOF
# }

resource "aws_instance" "kube-nodes" {
  ami = var.ami
  count = 2
  instance_type = var.instance_type
  security_groups = [data.aws_security_group.application_group.name]
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello All, Abhishek here! Devops is fun !!!" > /var/www/html/index.html
                python3 -m http.server 8080 & --directory /var/www/html > /var/log/static-server.log 2>&1 &
                EOF

  tags = {
    Name = "kube-node-${count.index + 1}"
  }
}