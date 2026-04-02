terraform {
  required_providers {
    helm       = {}
    kubernetes = {}
    onepassword = {
      source  = "1password/onepassword"
      version = "~> 1.0"
    }
  }
}
