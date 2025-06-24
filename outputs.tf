output "kube_master_public_ip" {
  value = aws_instance.kube_master.public_ip
}

output "kube_worker_public_ip" {
  value = aws_instance.kube_master.public_ip
}

