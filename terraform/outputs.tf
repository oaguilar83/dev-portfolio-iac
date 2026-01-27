output "instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "name_servers" {
  description = "The Route53 Zone Name Servers"
  value       = aws_route53_zone.public-zone.name_servers
}

output "private_key_path" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.web_server.public_ip}"
}
