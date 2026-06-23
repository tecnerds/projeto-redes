/*
  Backend S3 exemplo. Substitua os valores abaixo e execute
  `terraform init -reconfigure` ou forneça -backend-config.

  Atenção: não inclua secrets neste arquivo em repositórios públicos.
*/
terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_BUCKET"
    key            = "project-redes/dns1/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "REPLACE_WITH_DYNAMODB_TABLE"
  }
}
