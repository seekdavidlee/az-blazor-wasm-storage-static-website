# Introduction
This creates an environment for hosting a Blazor WASM on Azure Storage Static Website with Azure CDN as the frontend.

# Get Started
To create this APIM environment in your Azure subscription, please follow the steps below. 

1. Fork this git repo. See: https://docs.github.com/en/get-started/quickstart/fork-a-repo
2. Next, you must create a service principal with Contributor roles assigned to the a resource group you want to deploy this to.
3. Create the following secrets in your github org per environment. Be sure to populate with your desired values.

## Secrets
| Name | Comments |
| --- | --- |
| AZURE_CREDENTIALS | <pre>{<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"clientSecret": "", <br/>&nbsp;&nbsp;&nbsp;&nbsp;"subscriptionId": "",<br/>&nbsp;&nbsp;&nbsp;&nbsp;"tenantId": "" <br/>}</pre> |
| PREFIX | myblazordemo - or whatever name you would like for all your resources |
| RESOURCE_GROUP | my-blazor-demo - or whatever name you give to the resource group |
| MANAGED_USER_ID | a managed user assigned an appropriate role |