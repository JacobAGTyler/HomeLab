variable "cluster_issuer_name" {
  description = "Name of the cert-manager ClusterIssuer for Route53 DNS-01 certificates."
  type        = string
  default     = "letsencrypt-prod"
}

variable "acme_email" {
  description = "Email used for ACME registration."
  type        = string
  default     = "jacob@jacobagtyler.com"
}

variable "acme_server" {
  description = "ACME directory URL."
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "cluster_issuer_private_key_secret_name" {
  description = "Secret name cert-manager uses to store the ACME account private key."
  type        = string
  default     = "route53-issuer-account-key"
}

variable "route53_region" {
  description = "AWS region for Route53 API operations."
  type        = string
  default     = "us-east-1"
}

variable "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID for DNS-01 validation."
  type        = string
  default     = "Z1V49N7OG26NA3"
}

variable "onepassword_vault_name" {
  description = "1Password vault containing the Route53 IAM credentials item."
  type        = string
  default     = "Developer"
}

variable "onepassword_item_title" {
  description = "1Password item title for the Route53 IAM credentials."
  type        = string
  default     = "K3S Cert Manager - AWS IAM Credentials"
}

variable "route53_access_key_id" {
  description = "AWS access key ID with Route53 change permissions. When null, Terraform reads the username field from 1Password."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "route53_secret_access_key" {
  description = "AWS secret access key with Route53 change permissions. When null, Terraform reads the password field from 1Password."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "helm_timeout_seconds" {
  description = "Timeout in seconds for cert-manager Helm operations."
  type        = number
  default     = 900
}
