terraform {
  backend "s3" {
    bucket         = "ecommerce-tfstate-417a4fcc"   # bootstrap çıktısındaki bucket
    key            = "microservices/terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ecommerce-tf-lock"            # bootstrap çıktısındaki tablo
    encrypt        = true
  }
}
