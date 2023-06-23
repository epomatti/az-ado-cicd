# Azure ADO CI/CD

Building and deploying code from Azure DevOps to Azure Cloud.

Create the infrastructure:

```sh
terraform -chdir="azure" init
terraform -chdir="azure" apply -auto-approve
```

Connect to your project on ADO.

1. Create a project
2. Create the two pipelines.
