# Azure ADO CI/CD

Building and deploying code from Azure DevOps to Azure Cloud.

Create the infrastructure:

```sh
terraform -chdir="azure" init
terraform -chdir="azure" apply -auto-approve
```


