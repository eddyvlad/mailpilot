# MailPilot

Infrastructure as code for Gmail labels and filters using the Terraform provider `yamamoto-febc/gmailfilter`.
Goal: keep labels and server side filters in version control, automate hygiene, and document the workflow for importing,
planning, and applying changes.

**Full step by step guide:** https://eddyhidayat.com/article/terraform-gmail-filters

## Scope

* Manage Gmail **labels** and **filters** for a single personal Gmail account.
* Use **Application Default Credentials** from `gcloud`.
* Store Terraform state in **S3**.

---

## Prerequisites

* [Terraform CLI](https://www.terraform.io/downloads.html) (>= 1.3 recommended)
* [Google Cloud SDK (gcloud)](https://cloud.google.com/sdk/docs/install)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (optional, if you use S3
  backend and follow state bucket steps)
* [Terraformer](https://github.com/GoogleCloudPlatform/terraformer?tab=readme-ov-file#installation) (optional, if you
  want to import existing Gmail filters and labels)
* [jq](https://stedolan.github.io/jq/) (optional, if you want to inspect plan output)

Enable the Gmail API in your GCP project and create an OAuth 2.0 Client of type **Desktop app**.

Provider:

- gmailfilter: yamamoto-febc/gmailfilter == 1.1.0 (configured in terraform.tf)

Scopes used:

```
https://www.googleapis.com/auth/gmail.labels
https://www.googleapis.com/auth/gmail.settings.basic
```

Links you may need during setup:

* GCP project dashboard
  `https://console.cloud.google.com/home/dashboard?project=<project-id>`
* OAuth consent screen and App page
  `https://console.cloud.google.com/auth/overview?project=<project-id>`

> After creating the OAuth 2.0 Client, download the credentials JSON and store it at
`~/.config/mailpilot/client_secret_mailpilot.json` with mode `600`. Do not commit it.

---

## Authenticate with ADC (Application Default Credentials)

```bash
gcloud auth application-default login \
  --client-id-file ~/.config/mailpilot/client_secret_mailpilot.json \
  --scopes https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/gmail.labels,https://www.googleapis.com/auth/gmail.settings.basic
```

Quick verify:

```bash
# List labels
curl -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  https://gmail.googleapis.com/gmail/v1/users/me/labels

# List filters
curl -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  https://gmail.googleapis.com/gmail/v1/users/me/settings/filters
```

Notes

* If your OAuth app is in Testing mode, refresh tokens expire after 7 days. Re-run the ADC login when needed or publish
  the app to Production after setup.

---

## Project structure

```
.
├── terraform.tf          # required_providers + S3 backend (optional) + provider "gmailfilter" {}
├── labels.tf             # gmailfilter_label resources
├── filters.tf            # gmailfilter_filter resources
├── modules/              # modules for repeatable filters
└── README.md
```

## Modules

These opinionated modules create common filters under a specified label. Each module requires a label_id input to attach
created filters to your label resource defined in labels.tf. They are wired in main.tf.

- modules/bills-filter: Filters typical billing emails into the Bills label.
- modules/deliveries-filter: Filters shipment and delivery notifications into the Deliveries label.
- modules/receipts-filter: Filters general purchase receipts into the Receipts label.
- modules/transport-receipts-filter: Filters transit/ride receipts into the Receipts/Transport Receipts label.

Example wiring (see main.tf):

```hcl
module "bills_filter" {
  source   = "./modules/bills-filter"
  label_id = gmailfilter_label.bills.id
}
```

S3 backend example (add in `terraform.tf`):

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
```

## Creating terraform state bucket

You can use the following Terraform code to create a bucket for storing Terraform state.

```hcl
# Terraform State Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"

  tags = {
    Name        = "Terraform State Storage"
    Purpose     = "terraform-state"
    Criticality = "high"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

## Quick start

```bash
# Authenticate once (opens browser)
gcloud auth application-default login \
  --client-id-file ~/.config/mailpilot/client_secret_mailpilot.json \
  --scopes https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/gmail.labels,https://www.googleapis.com/auth/gmail.settings.basic

# Then initialize and review changes
terraform init
terraform plan
```

If you see a legacy provider error:

```bash
terraform state replace-provider \
  'registry.terraform.io/-/gmailfilter' \
  'registry.terraform.io/yamamoto-febc/gmailfilter'

terraform init -reconfigure -upgrade
```

---

## Import existing labels and filters with Terraformer

Generate HCL and a local state in a temp folder, then migrate to your S3 backend.

```bash
# Generate
mkdir -p tmp_import
terraformer import gmailfilter -r=label,filter -o tmp_import --path-pattern="{output}/" --compact=true

# Bring HCL into repo
cp tmp_import/gmailfilter/label/*.tf   ./labels.tf
cp tmp_import/gmailfilter/filter/*.tf  ./filters.tf

# Bring the local state in, then migrate
cp tmp_import/gmailfilter/terraform.tfstate ./terraform.tfstate
terraform init -migrate-state
```

Optional: rename resource addresses in state for readability.

```bash
terraform state mv gmailfilter_label.tfer--Receipts gmailfilter_label.receipts
# repeat for each mapping you keep in scripts/
```

---

## Sync state from Gmail without changing Gmail

Useful when you are not sure what Gmail currently has.

```bash
# Single resource
terraform plan -refresh-only -target=gmailfilter_label.newsletter
terraform apply -refresh-only -target=gmailfilter_label.newsletter

# Everything
terraform plan  -refresh-only
terraform apply -refresh-only
```

Then inspect:

```bash
terraform state show gmailfilter_label.newsletter
```

If you want Terraform to stop toggling list visibility for labels, add:

```hcl
lifecycle {
  ignore_changes = [label_list_visibility, message_list_visibility]
}
```

---

## Plan to JSON

```bash
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json
```

Handy queries:

```bash
jq '.resource_changes[] | {address, actions: .change.actions}' plan.json
jq '.resource_changes[] | select(.change.actions==["create"]) | .address' plan.json
jq '.resource_changes[] | select(.change.actions==["delete","create"]) | .address' plan.json
```

---

## Naming and conventions

* Use short, snake\_case Terraform resource names.
  Examples: `gmailfilter_label.receipts`, `gmailfilter_filter.github_notifications_archive`
* Reference system labels by their fixed names inside actions.
  Examples: `remove_label_ids = ["INBOX", "SPAM", "UNREAD"]`
* If Terraformer emitted `size = "0"`, remove that line or add `size_comparison` if you truly filter by size.
  Example:

  ```hcl
  criteria {
    size            = 5242880
    size_comparison = "larger"
  }
  ```

---

## Common tasks

Create a new label and a filter:

```hcl
resource "gmailfilter_label" "newsletters" {
  name = "Newsletters"
}

resource "gmailfilter_filter" "nl_archive" {
  criteria {
    from           = "news@newsletter.example"
    exclude_chats  = false
    has_attachment = false
  }
  action {
    add_label_ids = [gmailfilter_label.newsletters.id]
    remove_label_ids = ["INBOX"]
  }
}
```

Plan and apply in small batches:

```bash
terraform plan -target=gmailfilter_label.newsletters
terraform apply -target=gmailfilter_label.newsletters

terraform plan -target=gmailfilter_filter.nl_archive
terraform apply -target=gmailfilter_filter.nl_archive
```

---

## Security

* Never commit OAuth client JSON or `application_default_credentials.json`.
* Keep permissions strict: `chmod 600 ~/.config/mailpilot/client_secret_mailpilot.json`.
* If a credential leaks, delete the OAuth client in Cloud Console, create a new Desktop OAuth client, and run the ADC
  login again.

---

## Troubleshooting

Invalid legacy provider address

```bash
terraform state replace-provider \
  'registry.terraform.io/-/gmailfilter' \
  'registry.terraform.io/yamamoto-febc/gmailfilter'
```

Missing required argument for size

* Remove `size = "0"` entries or add `size_comparison`.

State is still local

```bash
terraform init -migrate-state
aws s3 ls s3://your-terraform-state-bucket/terraform.tfstate
terraform state pull | head
```

ADC token expired

* Rerun the ADC login command. Consider publishing the OAuth app to Production to avoid 7 day expiry.

---

## .gitignore suggestions

```
# Terraform local files
*.tfplan
*.tfstate
*.tfstate.backup
.crash
.terraform/
.terraform.lock.hcl

# Credentials
**/client_secret*.json
~/.config/mailpilot/client_secret_mailpilot.json
```

---

## Appendix

Revoke ADC if needed:

```bash
gcloud auth application-default revoke
```

List provider addresses held by state:

```bash
terraform state pull | jq -r '.resources[].provider' | sort -u
```

Export current state to JSON for auditing:

```bash
terraform show -json > state.json
```

List all Gmail's filters

```bash
TOKEN="$(gcloud auth application-default print-access-token)"
curl -s -H "Authorization: Bearer $TOKEN" \
  'https://gmail.googleapis.com/gmail/v1/users/me/settings/filters' \
| jq -r '.filter[] | {id, criteria, action}'
```

## Other resources

**Step by step guide:** https://eddyhidayat.com/article/terraform-gmail-filters
