Website CPU Scale Cloud Run
===========

Requirements
------------
- Docker ~> 20
- Docker Compose ~> 2
- Terraform ~> 1.9

Terraform Workspace Environments
-------------------------------
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `GOOGLE_CREDENTIALS` | service account key on 1 line to authenticate from GCP , not required if TFC_GCP_PROVIDER_AUTH is enabled  | `string` | `""` | yes |
| `TFC_GCP_PROVIDER_AUTH` | active workflow OIDC authenticate | `bool` | `""` | yes |
| `TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL` | service account email to binding to workload identity pool | `string` | `""` | no |
| `TFC_GCP_WORKLOAD_PROVIDER_NAME` | workload identity provider pool name | `string` | `` | no |
| `gcp_workspace` | terraform workspace on create project | `string` | `` | yes |
| `region` | data center region on deploy resources | `string` | `""` | yes |
| `zone` | zone on data center to deploy resources | `string` | `` | yes |

IAM Custom role permissions list
--------------------------------
- create file custom_role.yaml
```yaml
title: "terraform-scalingwebsite-development"
description: "roleset permission to terraform manage resources"
stage: "GA"
permissions:
  - artifactregistry.repositories.create
  - artifactregistry.repositories.delete
  - artifactregistry.repositories.get
  - compute.backendServices.create
  - compute.backendServices.delete
  - compute.backendServices.get
  - compute.backendServices.setSecurityPolicy
  - compute.backendServices.use
  - compute.globalAddresses.create
  - compute.globalAddresses.delete
  - compute.globalAddresses.get
  - compute.globalAddresses.use
  - compute.globalForwardingRules.create
  - compute.globalForwardingRules.delete
  - compute.globalForwardingRules.get
  - compute.globalOperations.get
  - compute.regionNetworkEndpointGroups.create
  - compute.regionNetworkEndpointGroups.delete
  - compute.regionNetworkEndpointGroups.get
  - compute.regionNetworkEndpointGroups.use
  - compute.regionOperations.get
  - compute.securityPolicies.create
  - compute.securityPolicies.delete
  - compute.securityPolicies.get
  - compute.securityPolicies.use
  - compute.sslCertificates.create
  - compute.sslCertificates.delete
  - compute.sslCertificates.get
  - compute.targetHttpProxies.create
  - compute.targetHttpProxies.delete
  - compute.targetHttpProxies.get
  - compute.targetHttpProxies.use
  - compute.targetHttpsProxies.create
  - compute.targetHttpsProxies.delete
  - compute.targetHttpsProxies.get
  - compute.targetHttpsProxies.use
  - compute.urlMaps.create
  - compute.urlMaps.delete
  - compute.urlMaps.get
  - compute.urlMaps.use
  - iam.serviceAccounts.actAs
  - iam.serviceAccounts.create
  - iam.serviceAccounts.delete
  - iam.serviceAccounts.get
  - resourcemanager.projects.get
  - run.services.create
  - run.services.delete
  - run.services.get
  - run.services.getIamPolicy
  - run.services.setIamPolicy
  - serviceusage.quotas.get
  - serviceusage.services.disable
  - serviceusage.services.enable
  - serviceusage.services.get
  - serviceusage.services.list
  - serviceusage.services.use
```
- Create custom role
```bash
$ gcloud iam roles create [CUSTOM_ROLE_NAME] --project=[PROJECT_ID] --file=custom_role.yaml
```

[Create ODIC Provider Flow authentication](https://astrafy.io/the-hub/blog/technical/authenticate-to-google-cloud-from-terraform-cloud-using-workload-identity)
---
- Create Workload Identity Pool
```bash
$ gcloud iam workload-identity-pools create [POOL_NAME] \
--location="global" \
--description="Pool for authentication flow from terrraform cloud workspace" \
--display-name="terraform demo scale website"
```
- Create Provider OIDC
```bash
$ gcloud iam workload-identity-pools providers create-oidc terraform \
--location="global" \
--workload-identity-pool="[POOL_NAME]" \
--issuer-uri="https://app.terraform.io" \
--attribute-mapping="google.subject=assertion.sub,attribute.terraform_workspace_name=assertion.terraform_workspace_name" \
--attribute-condition="assertion.terraform_organization_name==\"[ORG_NAME]\""
```
- Create Service Account
```bash
º gcloud iam service-accounts create [SERVICE_ACCOUNT_NAME] \
--display-name="[SERVICE_ACCOUNT_DISPLAY_NAME]"
```
- Add IAM Policy Binding
```bash
$ gcloud projects add-iam-policy-binding [PROJECT_ID] \
--member serviceAccount:[SERVICE_ACCOUNT_EMAIL] \
--role roles/[CUSTOM_ROLE_NAME]
```
- Add IAM Policy Binding to Workload Identity Pool
```bash
$ gcloud iam service-accounts add-iam-policy-binding [SERVICE_ACCOUNT_EMAIL] \
--role=roles/iam.workloadIdentityUser \
--member="principal://iam.googleapis.com/projects/[PROJECT_ID]/locations/global/workloadIdentityPools/[POOL_NAME]/subject/organization:[ORG_NAME]:project:[PROJECT_NAME]:workspace:[WORKSPACE_NAME]:run_phase:[RUN_PHASE]"
```

Workspace Terraform Environment
![env](https://framerusercontent.com/images/EImpNLRdqFdtP56fxFnPPUTDxrQ.png)

- TFC_GCP_PROVIDER_AUTH = true
- TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL = [SERVICE_ACCOUNT_NAME]@[PROJECT_ID].iam.gserviceaccount.com
- TFC_GCP_WORKLOAD_PROVIDER_NAME = projects/[PROJECT_NUMBER]/locations/global/workloadIdentityPools/[POOL_NAME]/providers/[PROVIDER_NAME]


Convention Name for Terraform Workspace
---------------------------------------
- [PROVIDER]-[PROJECT_NAME]-[ENVIRONMENT]

Run Project
-----------
- Create file [.terraformrc](https://www.terraform.io/docs/cli/config/config-file.html) in your home directory
- If need use remote backend create file [backend.tf](https://www.terraform.io/docs/language/settings/backends/configuration.html)in your project directory
```hcl
terraform {
  backend "remote" {
    organization = "[ORG_NAME]"
    workspaces {
      name = "[WORKSPACE_NAME]"
    }
  }
}
```
docker-compose.yml
```yaml
services:
  project:
    image: hashicorp/terraform:1.9.4
    environment:
      GOOGLE_CREDENTIALS:
      TF_VAR_project:
      TF_VAR_org_id:
      TF_VAR_folder_id:
      TF_VAR_billing_account_id:
    working_dir: /terraform/gcp/project
    volumes:
      - "./project:/terraform/gcp/project"
      - "./.terraformrc:/root/.terraformrc"
  website:
    image: hashicorp/terraform:1.9.4
    environment:
      GOOGLE_CREDENTIALS:
      TF_VAR_project:
      TF_VAR_org_id:
      TF_VAR_folder_id:
      TF_VAR_billing_account_id:
    working_dir: /terraform/website
    volumes:
      - "./website:/terraform/website"
      - "./.terraformrc:/root/.terraformrc"
```
- Run project
```bash
$ docker-compose run --rm aws website init
$ docker-compose run --rm aws website plan
$ docker-compose run --rm aws website apply
```