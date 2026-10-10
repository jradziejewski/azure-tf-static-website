# Azure Static Website with Visitor Counter

A static "Hello Azure!" page with a serverless visitor counter, provisioned with Terraform and deployed by GitHub Actions.

## Architecture

```
Browser ──> Azure Storage static website ($web/index.html)
   │
   └─fetch──> Azure Function App (Python 3.11, Linux, Consumption Y1)
                 GET /api/get_count
                    └──> Cosmos DB (serverless, SQL API): visitors-db/visitors
```

## Resources (`main.tf`)

- Resource group (`switzerlandnorth`)
- Storage account with static website hosting, plus the `index.html` blob
- Cosmos DB account (serverless), database `visitors-db`, container `visitors`
- Storage account, Linux service plan (Y1) and Function App for the API
- Function App CORS allows only the static website origin

`index.html` is rendered with `templatefile`, which injects the API URL.

## Layout

| Path | Purpose |
|---|---|
| `main.tf`, `providers.tf`, `outputs.tf` | Terraform configuration |
| `index.html` | Frontend template |
| `api/` | Azure Function (`get_count`), which atomically increments and returns the counter |
| `deploy.sh` | Local deploy and smoke tests |
| `.github/workflows/deploy.yml` | CI/CD pipeline |

## Prerequisites

- Terraform >= 1.0, Azure CLI logged in
- An existing remote state backend: resource group `rg-tfstate-dev`, storage account `sttfstate130022`, container `tfstate` (see `providers.tf`). It authenticates with OIDC.

## Deploy locally

```sh
terraform init
./deploy.sh
```

`deploy.sh` runs `terraform apply` and checks that the site returns 200 and contains "Hello Azure!". It does not deploy the function code. The pipeline does that.

## CI/CD

On push to `main`, `.github/workflows/deploy.yml`:

1. Runs a tfsec scan
2. Logs in to Azure with OIDC
3. Runs `terraform init` and `terraform apply`
4. Installs the API dependencies and deploys the Function App
5. Runs integration tests against the site and API

Required repository secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.

Note: every `GET /api/get_count` increments the counter, including the CI integration tests.
