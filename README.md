# jenkins_pipelines

 This demo is related to 
 - An app and a jenkins configuration launched from terraform to EC2 instances and ElasticBeanStalk service.
 
 - A pipeline to launch updates after a change is pushed to source control and deployed to BeanStalk App.

## Use jenkins file
- Access console to Jenkins
```bash
    http://<YOUR-IP-OR-FQDN>:8080/
```

- Init administrator Password with docker
```bash
    docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
```


## TERRAFORM
Some basic commands to run terraform
```bash
terraform fmt
terraform init
terraform plan -out deploy.tfplan
terraform apply deploy.tfplan
```