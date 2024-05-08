terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      Project = "intermittent-harvester"
    }
  }
}


provider "aws" {
  alias  = "hongkong"
  region = "ap-east-1"
  default_tags {
    tags = {
      Project = "intermittent-harvester"
    }
  }
}

provider "aws" {
  alias  = "brazil"
  region = "sa-east-1"
  default_tags {
    tags = {
      Project = "intermittent-harvester"
    }
  }
}
