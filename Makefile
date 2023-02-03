PROJECT := github.com/mohik98/orion

KIND_CLUSTER_NAME := orion-test
KIND_VERSION      := v0.17.0
KIND_IMAGE        := kindest/node:v1.26.0
KIND              := kind-$(KIND_VERSION)

PATH := $(PATH):$(shell pwd)/bin

build-cni:
	go build -o bin/orion-cni $(PROJECT)/cmd/orion-cni

create-cluster: $(KIND)
	$(KIND) create cluster --name $(KIND_CLUSTER_NAME) --image $(KIND_IMAGE) --config hack/kind-config.yaml

delete-cluster: $(KIND)
	$(KIND) delete cluster --name $(KIND_CLUSTER_NAME)

$(KIND):
ifneq ($(shell test -f bin/$(KIND) && echo exists),exists) # do not download if present
	$(info downloading kind-$(KIND_VERSION)...)
	@mkdir -p bin
	@curl --location --show-error --output bin/$(KIND) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-linux-amd64
	@chmod +x bin/$(KIND)
endif
