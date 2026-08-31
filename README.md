# Azure Platform Automation Lab

A secure Azure platform automation reference implementation using **Terraform**, **GitHub Actions**, and **OIDC federation**.

This project demonstrates how infrastructure validation, cloud authentication, planning, and protected deployment can be separated into distinct CI/CD stages.

> This repository is a public portfolio project using generic lab resources only. It does not contain employer or client source code, credentials, or infrastructure configuration.

## Architecture

```text
Developer / Pull Request
        │
        ▼
┌─────────────────────────────┐
│      Terraform CI           │
├─────────────────────────────┤
│ terraform fmt               │
│ terraform init              │
│ terraform validate          │
└─────────────────────────────┘

Manual Terraform Plan
        │
        ▼
GitHub Actions
        │
        │ OIDC
        ▼
Microsoft Entra ID
        │
        ▼
Azure Subscription
        │
        ▼
terraform plan

Manual Terraform Apply
        │
        ▼
Type APPLY
        │
        ▼
GitHub Environment Approval
        │
        ▼
GitHub OIDC Authentication
        │
        ▼
terraform plan
        │
        ▼
terraform apply
```

## Infrastructure

The Terraform configuration defines:

- Azure Resource Group
- Azure Storage Account
- Private Blob Container

The example configuration applies secure defaults such as:

- Minimum TLS version 1.2
- Public nested-item access disabled
- Private Blob container access
- Consistent resource tagging
- Variable validation for Azure resource naming

## Terraform Validation

Infrastructure changes can be validated locally without deploying Azure resources.

```bash
cd infra

terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The GitHub Actions Terraform CI workflow performs the same checks automatically.

No Azure credentials are required for the validation-only workflow.

## GitHub Actions Workflows

### Terraform CI

The Terraform CI workflow runs formatting and configuration validation.

It is triggered by:

- Pushes affecting Terraform infrastructure
- Pull requests targeting `main`
- Manual workflow execution

The workflow uses least-privilege permissions:

```yaml
permissions:
  contents: read
```

### Azure OIDC Terraform Plan

The plan workflow uses GitHub Actions OIDC federation to authenticate to Azure.

```text
GitHub Actions
      │
      │ short-lived OIDC token
      ▼
Microsoft Entra ID
      │
      ▼
Federated Credential
      │
      ▼
Azure
```

No long-lived Azure client secret is required.

The workflow requires:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

and the repository variable:

```text
AZURE_STORAGE_ACCOUNT_NAME
```

The authentication flow depends on an Entra application/service principal with a GitHub federated credential.

### Protected Terraform Apply

Infrastructure deployment is intentionally separated from validation and planning.

The apply workflow requires:

1. Manual `workflow_dispatch`
2. An explicit `APPLY` confirmation value
3. Access to the protected `production` GitHub Environment
4. Azure authentication through OIDC
5. A successful Terraform plan
6. Terraform apply of the generated plan

This provides multiple controls before infrastructure changes are deployed.

## Why OIDC?

Traditional CI/CD authentication often stores a long-lived client secret:

```text
GitHub Secret
     │
     ▼
Azure Client Secret
     │
     ▼
Azure Authentication
```

This project instead demonstrates federated identity:

```text
GitHub Workflow Identity
        │
        ▼
Short-Lived OIDC Token
        │
        ▼
Microsoft Entra Federated Trust
        │
        ▼
Azure Authentication
```

Benefits include:

- No long-lived client secret stored in GitHub
- Reduced secret rotation requirements
- Short-lived authentication credentials
- Identity tied to GitHub workflow context
- Better separation of authentication and authorization

## Project Structure

```text
azure-platform-automation-lab/
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml
│       ├── azure-oidc.yml
│       └── terraform-apply.yml
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── .gitignore
├── LICENSE
└── README.md
```

## Local Development

Initialize Terraform:

```bash
cd infra
terraform init
```

Format:

```bash
terraform fmt -recursive
```

Validate:

```bash
terraform validate
```

A real Azure deployment is not required to validate the Terraform configuration.

## CI/CD Security Design

| Layer | Control |
|---|---|
| Source change | Git / pull request workflow |
| IaC formatting | `terraform fmt -check` |
| IaC validation | `terraform validate` |
| Workflow permissions | Explicit least-privilege GitHub permissions |
| Cloud authentication | GitHub Actions OIDC |
| Planning | Separate Terraform plan workflow |
| Deployment trigger | Manual workflow execution |
| Deployment confirmation | Explicit `APPLY` input |
| Deployment authorization | Protected GitHub Environment |
| Deployment | Terraform apply of reviewed plan |

## Design Principles

- Infrastructure should be defined as code.
- Infrastructure should be validated before cloud authentication is required.
- CI/CD workflows should follow least privilege.
- Long-lived cloud credentials should be avoided where federation is available.
- Planning and deployment should be separate stages.
- Production deployment should require explicit authorization.
- Secure configuration should be the default.
- Public examples should not expose real organizational infrastructure.

## Terraform State

This lab currently focuses on infrastructure definition, validation, OIDC authentication, planning, and deployment controls.

A production implementation would normally use a protected remote Terraform backend rather than relying on local state.

For Azure, this could include Azure Storage with appropriate access controls, state protection, and environment isolation.

## Future Enhancements

Potential extensions include:

- Azure Storage remote Terraform backend
- State locking and environment isolation
- Terraform security scanning with Checkov or tfsec
- GitHub dependency review
- Policy-as-code validation
- Multiple environments such as development, staging, and production
- Reusable Terraform modules
- Reusable GitHub Actions workflows
- Azure Key Vault integration
- OIDC subject restrictions for branches and environments
- SBOM and infrastructure provenance

## Technology Stack

**Microsoft Azure | Terraform | GitHub Actions | OIDC | Microsoft Entra ID | Infrastructure as Code | CI/CD | DevSecOps | Cloud Platform Engineering**

## Purpose

This project demonstrates practical Cloud Platform and DevSecOps patterns for secure Azure infrastructure delivery.

The emphasis is on authentication, authorization boundaries, infrastructure validation, and controlled deployment rather than application complexity.