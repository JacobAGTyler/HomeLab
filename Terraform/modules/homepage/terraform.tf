terraform {
  required_providers {
    kubernetes = {
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }

    onepassword = {
      source  = "1password/onepassword"
      version = "~> 1.0"
    }
  }
}