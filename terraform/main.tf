terraform {
  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "1.45.0"
    }
  }
}

provider "huaweicloud" {
  region     = "ap-southeast-1" # Singapore as an example
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "huaweicloud_vpc" "my_vpc" {
  name = "my-vpc"
  cidr = "192.168.0.0/16"
}
