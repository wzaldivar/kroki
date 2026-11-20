# Fork-only overrides, loaded after docker-bake.hcl and docker-bake-release.hcl by the
# "Publish latest (fork)" workflow:
#   docker buildx bake -f docker-bake.hcl -f docker-bake-release.hcl -f docker-bake-fork.hcl kroki companion-images
#
# - every image is published to this fork's GHCR namespace instead of Docker Hub
# - ditaa and UMLet are built from tools/ in the same build, instead of copying the binaries
#   published by upstream (ghcr.io/yuzutech/kroki-builder-*), so the fork's changes to
#   tools/ditaa and tools/umlet end up in the kroki image
#
# This is a new file on purpose: upstream files are left untouched so merging `main`
# into `releases` never conflicts.

variable "REGISTRY" {
  default = "ghcr.io/wzaldivar"
}

variable "SOURCE_URL" {
  default = "https://github.com/wzaldivar/kroki"
}

# The exact references of the FROM instructions in server/ops/docker/Dockerfile
# (e.g. ghcr.io/yuzutech/kroki-builder-ditaa:1.0.3), read by the workflow:
# a named build context only replaces a FROM whose reference matches it exactly.
variable "DITAA_IMAGE" {
}

variable "UMLET_IMAGE" {
}

target "oci-labels" {
  labels = {
    "org.opencontainers.image.source" = SOURCE_URL
    "org.opencontainers.image.url" = SOURCE_URL
  }
}

# Final stage of tools/<tool>/Dockerfile (a scratch image with /opt/<tool>),
# built with the version set by the VERSION argument of that Dockerfile.
target "fork-ditaa" {
  context = "tools/ditaa"
  cache-from = cache_from("ditaa")
  cache-to = cache_to("ditaa")
}

target "fork-umlet" {
  context = "tools/umlet"
  cache-from = cache_from("umlet")
  cache-to = cache_to("umlet")
}

target "kroki" {
  contexts = {
    (DITAA_IMAGE) = "target:fork-ditaa"
    (UMLET_IMAGE) = "target:fork-umlet"
  }
  tags = release_tags("${REGISTRY}/kroki")
  output = release_output("${REGISTRY}/kroki")
}

target "kroki-mermaid" {
  tags = release_tags("${REGISTRY}/kroki-mermaid")
  output = release_output("${REGISTRY}/kroki-mermaid")
}

target "kroki-bpmn" {
  tags = release_tags("${REGISTRY}/kroki-bpmn")
  output = release_output("${REGISTRY}/kroki-bpmn")
}

target "kroki-excalidraw" {
  tags = release_tags("${REGISTRY}/kroki-excalidraw")
  output = release_output("${REGISTRY}/kroki-excalidraw")
}

target "kroki-diagramsnet" {
  tags = release_tags("${REGISTRY}/kroki-diagramsnet")
  output = release_output("${REGISTRY}/kroki-diagramsnet")
}
