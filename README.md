# Azure ADO CI/CD

Building and deploying code from Azure DevOps to Azure Cloud.

Create the infrastructure:

```sh
terraform -chdir="azure" init
terraform -chdir="azure" apply -auto-approve
```

Once that is done, create a secret in the App Registration.

Connect to your project on ADO and follow these steps:

1. Create the Service Connection using the Terraform output.
1. Create the Backend pipeline using the `azure-pipelines-backend.yml` file.
2. Create the Frontend pipeline using the `azure-pipelines-frontend.yml` file.

Use Releases for production use cases.
