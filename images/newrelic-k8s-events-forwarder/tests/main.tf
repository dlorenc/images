terraform {
  required_providers {
    oci  = { source = "chainguard-dev/oci" }
    helm = { source = "hashicorp/helm" }
  }
}

variable "license_key" {}

variable "digest" {
  description = "The image digests to run tests over."
  type        = string
}

locals { parsed = provider::oci::parse(var.digest) }

resource "random_pet" "suffix" {}

resource "random_integer" "random_port" {
  min = 1025
  max = 65534
}

resource "helm_release" "nri-bundle" {
  name             = "newrelic-kef-${random_pet.suffix.id}"
  namespace        = "newrelic-kef-${random_pet.suffix.id}"
  repository       = "https://helm-charts.newrelic.com"
  chart            = "nri-bundle"
  create_namespace = true

  values = [
    jsonencode({
      global = {
        cluster    = "test"
        licenseKey = var.license_key
      }

      newrelic-infrastructure = {
        privileged = true
        kubelet = {
          // We use some extra volume mounts needed when running in a docker-in-docker environment
          extraVolumeMounts = [{
            mountPath = "/var/run/newrelic-infra"
            name      = "var-run-newrelic-infra"
          }]
          extraVolumes = [{
            hostPath = {
              path = "/var/run/newrelic-infra"
            }
            name = "var-run-newrelic-infra"
          }]
        }
        common = {
          agentConfig = {
            # This agent uses the host network so we were getting port
            # conflicts. This has the potential to be a flaky test due
            # to being random and not gauranteed to be a free port.
            http_server_port = random_integer.random_port.result
          }
        }
        images = {
          forwarder = {
            registry   = local.parsed.registry
            repository = local.parsed.repo
            tag        = local.parsed.pseudo_tag
          }
        }
      }

      nri-kube-events = {
        enabled = true
        images = {
          agent = {
            registry   = local.parsed.registry
            repository = local.parsed.repo
            tag        = local.parsed.pseudo_tag
          }
        }
      }

      kube-state-metrics = {
        enabled = true
      }

      nri-metadata-injection       = { enabled = false }
      newrelic-pixie               = { enabled = false }
      pixie-chart                  = { enabled = false }
      newrelic-infra-operator      = { enabled = false }
      newrelic-k8s-metrics-adapter = { enabled = false }
    })
  ]
}

data "oci_exec_test" "check-deployment" {
  digest      = var.digest
  script      = "./helm.sh"
  working_dir = path.module
  depends_on  = [helm_release.nri-bundle]

  env = [
    {
      name  = "NAMESPACE"
      value = helm_release.nri-bundle.namespace
    },
    {
      name  = "NAME"
      value = helm_release.nri-bundle.name
    }
  ]
}

module "helm_cleanup" {
  source     = "../../../tflib/helm-cleanup"
  name       = helm_release.nri-bundle.id
  namespace  = helm_release.nri-bundle.namespace
  depends_on = [data.oci_exec_test.check-deployment]
}
