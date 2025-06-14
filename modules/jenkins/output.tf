output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
  description = "Public url of the Jenkins"
}

output "jenkins_password" {
  value = file("./modules/jenkins/jenkins_password.txt")
}
