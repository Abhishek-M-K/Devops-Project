# Purpose: Define the outputs for the Terraform configuration.
# Store output locally in inventory file for further Ansible Config Management.
output "public_ips" {
  value = aws_instance.kube-nodes[*].public_ip
}

# Generate inventory.ini file for Ansible
resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory.ini" 
  content  = join("\n", [
      "[kube-nodes]",
      join("\n", [for ip in aws_instance.kube-nodes[*].public_ip : "ubuntu@${ip}"])
  ])
}
