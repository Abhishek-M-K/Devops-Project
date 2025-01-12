resource "aws_s3_object" "inventory_bucket" {
  bucket = "ansible-policy"
  key = "inventory.ini"
  content  = join("\n", [
      "[kube-nodes]",
      join("\n", [for ip in aws_instance.kube-nodes[*].public_ip : "ubuntu@${ip}"])
  ])
}