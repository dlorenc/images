terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
  }
}

variable "digest" {
  description = "The image digest to run tests over."
}

data "oci_exec_test" "help" {
  digest = var.digest
  script = "docker run --rm $IMAGE_NAME -h 2>&1 | grep Usage"
}

data "oci_exec_test" "cow" {
  digest = var.digest
  script = "docker run --rm $IMAGE_NAME cow | grep cow"
}
