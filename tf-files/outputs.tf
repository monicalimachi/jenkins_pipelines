output "instance-public-ip" {
  value = aws_instance.ec2_jenkins.public_ip
}