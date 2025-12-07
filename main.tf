terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    skopeo2 = {
      source  = "bsquare-corp/skopeo2"
      version = "~> 1.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = var.aws_region
}

// Docker and also the skopeo2 providers rely on the github pipeline having logged into GHCR
provider "docker" {
  host = "https://ghcr.io"
  registry_auth {
    address       = "ghcr.io"
    auth_disabled = true
  }
}

data "aws_ecr_authorization_token" "dest-ecr" {}

provider "skopeo2" {
  destination {
    login_username     = data.aws_ecr_authorization_token.dest-ecr.user_name
    login_password     = data.aws_ecr_authorization_token.dest-ecr.password
    registry_auth_file = "/tmp/skopeo2_auth.json"
  }
}
