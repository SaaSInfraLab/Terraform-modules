terraform {
  backend "s3" {
    bucket         = "saas-infra-lab-terraform-state"
    key            = "saas-infra-lab/tenants/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
