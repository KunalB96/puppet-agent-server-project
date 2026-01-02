output "puppet_server_public_ip" {
  description = "Public IP of the Puppet Server"
  value       = aws_instance.puppet_server.public_ip
}

output "puppet_server_private_ip" {
  description = "Private IP of the Puppet Server"
  value       = aws_instance.puppet_server.private_ip
}

output "puppet_agent_public_ip" {
  description = "Public IP of the Puppet Agent"
  value       = aws_instance.puppet_agent.public_ip
}

output "puppet_agent_private_ip" {
  description = "Private IP of the Puppet Agent"
  value       = aws_instance.puppet_agent.private_ip
}

output "apache_url" {
  description = "URL to access Apache on the agent"
  value       = "http://${aws_instance.puppet_agent.public_ip}"
}

output "ssh_commands" {
  description = "SSH commands to access instances"
  value = {
    puppet_server = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.puppet_server.public_ip}"
    puppet_agent  = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.puppet_agent.public_ip}"
  }
}