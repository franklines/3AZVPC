module "terraform-vpc" {
    source = "../modules/vpc"
    aws_region = "us-east-2"
    vpc_name = "myvpcname"
}
