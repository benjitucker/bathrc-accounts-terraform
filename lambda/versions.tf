terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
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
  required_version = ">= 0.13"
}
