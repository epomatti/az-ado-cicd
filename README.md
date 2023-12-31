# Azure Cloud + ADO CI/CD

Building and deploying code from Azure DevOps to Azure Cloud.

Create the infrastructure:

```sh
terraform -chdir="azure" init
terraform -chdir="azure" apply -auto-approve
```

Once that is done, create a secret in the App Registration.

Connect to your project on ADO and follow these steps:

1. Create the Service Connection using the Terraform output.
2. Create the Backend pipeline using the `azure-pipelines-backend.yml` file.
3. Create the Frontend pipeline using the `azure-pipelines-frontend.yml` file. You'll need to set the `deployment_token` secret variable.

Use Releases for production use cases.
