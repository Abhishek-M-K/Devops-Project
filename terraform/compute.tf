# EC2 Instances - Ubuntu 20.04 LTS

resource "aws_instance" "kube-nodes" {
  ami = var.ami
  count = 2
  instance_type = var.instance_type
  security_groups = [data.aws_security_group.application_group.name]
  key_name = var.key_pair 
  user_data = <<-EOF
                #!/bin/bash
                apt-get update
                apt-get install -y python3 nginx

                # Create a simple HTML file
                mkdir -p /var/www/html
                echo "Hello All, Abhishek here! Devops is fun !!!" > /var/www/html/index.html

                # Config the Nginx service
                cat > /etc/nginx/sites-available/default <<NGINXCONF
                server {
                  listen 80;

                  # Serve html 
                  location / {
                    root /var/www/html;
                    index index.html;
                  }

                  # Tunnel proxy reqs to ElysiaJs App
                  location /api {
                    proxy_pass http://127.0.0.1:8888; 
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection 'upgrade';
                    proxy_set_header Host $host;
                    proxy_cache_bypass $http_upgrade;
                  }
                }
                NGINXCONF # End of config

                # Restart system and Nginx service
                systemctl restart nginx

                EOF

  tags = {
    Name = "kube-node-${count.index + 1}"
  }
}