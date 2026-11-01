terraform {
  required_version = ">= 1.4"
}

# terraform_data needs no provider and no cloud account, so the sample plans anywhere.
resource "terraform_data" "endpoint" {
  input = {
    public = false
  }
}
