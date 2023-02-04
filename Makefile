PROJECT := github.com/mohik98/orion
IMAGE   := mohik/orion
BRANCH  ?= $(subst main,,$(shell git rev-parse --abbrev-ref HEAD))
VERSION ?= $(if $(BRANCH),$(BRANCH)-$(shell git rev-parse --short HEAD),$(shell git describe --tags --always --dirty --match=v*))

KIND_CLUSTER_NAME := orion-test
KIND_VERSION      := v0.17.0
KIND_IMAGE        := kindest/node:v1.26.0
KIND              := kind-$(KIND_VERSION)

KUSTOMIZE_VERSION := v5.0.0
KUSTOMIZE         := kustomize-$(KUSTOMIZE_VERSION)

PATH := $(PATH):$(shell pwd)/bin

build-cni:
	go build -o bin/orion-cni $(PROJECT)/cmd/orion-cni

build-daemon:
	go build -o bin/orion-daemon $(PROJECT)/cmd/orion-daemon

build-controller:
	go build -o bin/orion-controller $(PROJECT)/cmd/orion-controller

docker-build-all: docker-build-cni docker-build-daemon docker-build-controller

docker-build-cni:
	docker build . -t $(IMAGE)/cni:$(VERSION) -f build/cni/Dockerfile

docker-push-cni:
	docker push $(IMAGE)/cni:$(VERSION)

docker-build-daemon:
	docker build . -t $(IMAGE)/daemon:$(VERSION) -f build/daemon/Dockerfile

docker-push-daemon:
	docker push $(IMAGE)/daemon:$(VERSION)

docker-build-controller:
	docker build . -t $(IMAGE)/controller:$(VERSION) -f build/controller/Dockerfile

docker-push-controller:
	docker push $(IMAGE)/controller:$(VERSION)

.PHONY: deploy
deploy-dev:
	kustomize build deploy \
	| sed -e 's|image: __DAEMON_IMAGE__|image: $(IMAGE)/daemon:$(VERSION)|' \
	| sed -e 's|image: __CNI_IMAGE__|image: $(IMAGE)/cni:$(VERSION)|' \
	| kubectl --context kind-$(KIND_CLUSTER_NAME) apply -f -

create-cluster: $(KIND)
	$(KIND) create cluster --name $(KIND_CLUSTER_NAME) --image $(KIND_IMAGE) --config hack/kind-config.yaml

delete-cluster: $(KIND)
	$(KIND) delete cluster --name $(KIND_CLUSTER_NAME)

load-images: $(KIND)
	$(KIND) load docker-image $(IMAGE)/cni:$(VERSION) --name $(KIND_CLUSTER_NAME)
	$(KIND) load docker-image $(IMAGE)/daemon:$(VERSION) --name $(KIND_CLUSTER_NAME)
	$(KIND) load docker-image $(IMAGE)/controller:$(VERSION) --name $(KIND_CLUSTER_NAME)

$(KIND):
ifneq ($(shell test -f bin/$(KIND) && echo exists),exists) # do not download if present
	$(info downloading kind-$(KIND_VERSION)...)
	@mkdir -p bin
	@curl --location --show-error --output bin/$(KIND) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-linux-amd64
	@chmod +x bin/$(KIND)
endif
