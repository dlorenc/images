terraform {
  required_providers {
    oci = { source = "chainguard-dev/oci" }
  }
}

variable "digest" {
  description = "The image digest to run tests over."
}

data "oci_exec_test" "version" {
  digest = var.digest
  script = "docker run --rm $IMAGE_NAME --version"
}


locals { parsed = provider::oci::parse(var.digest) }

resource "random_id" "hex" { byte_length = 4 }

resource "random_integer" "port" {
  min = 9100
  max = 60000
}

resource "helm_release" "bitnami" {
  name       = "prometheus-node-bitnami-${random_id.hex.hex}"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "node-exporter"

  namespace        = "prometheus-node-bitnami-${random_id.hex.hex}"
  create_namespace = true

  values = [
    jsonencode({
      service = {
        ports = {
          metrics = random_integer.port.result
        }
      }
      image = {
        registry   = local.parsed.registry
        repository = local.parsed.repo
        digest     = local.parsed.digest
      }
  })]
}

module "helm_cleanup_bitnami" {
  source    = "../../../tflib/helm-cleanup"
  name      = helm_release.bitnami.id
  namespace = helm_release.bitnami.namespace
}
