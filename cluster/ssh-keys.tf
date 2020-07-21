variable "key-name" {}
variable "public-key" {}

resource "aws_key_pair" "deployer" {
  key_name   = var.key-name
  public_key = var.public-key
}

