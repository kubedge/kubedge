
# Image URL to use all building/pushing image targets
COMPONENT        ?= kubedge
VERSION_V1       ?= 0.2.24
DHUBREPO         ?= kubedge1/${COMPONENT}
DHUBREPO_DEV     ?= kubedge1/${COMPONENT}-dev
DHUBREPO_AMD64   ?= kubedge1/${COMPONENT}-amd64
DHUBREPO_ARM32V7 ?= kubedge1/${COMPONENT}-arm32v7
DHUBREPO_ARM64V8 ?= kubedge1/${COMPONENT}-arm64v8
DOCKER_NAMESPACE ?= kubedge1
IMG              ?= ${DHUBREPO}:v${VERSION_V1}
IMG_DEV          ?= ${DHUBREPO_DEV}:v${VERSION_V1}
IMG_AMD64        ?= ${DHUBREPO_AMD64}:v${VERSION_V1}
IMG_ARM32V7      ?= ${DHUBREPO_ARM32V7}:v${VERSION_V1}
IMG_ARM64V8      ?= ${DHUBREPO_ARM64V8}:v${VERSION_V1}
K8S_NAMESPACE    ?= default

all: docker-build

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output
	rm -fr config/crds
	rm -fr go.sum

# Run go fmt against code
fmt: setup
	go fmt ./cmd/...

# Run go vet against code
vet-v1: fmt
	go vet -composites=false -tags=v1 ./cmd/...

# Build the docker image
docker-build: fmt vet-v1 docker-build-dev docker-build-amd64 docker-build-arm32v7 docker-build-arm64v8

docker-build-dev:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/kubedge -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile -t ${IMG_DEV}
	docker tag ${IMG_DEV} ${DHUBREPO_DEV}:latest

docker-build-amd64:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/kubedge -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.amd64 -t ${IMG_AMD64}
	docker tag ${IMG_AMD64} ${DHUBREPO_AMD64}:latest

docker-build-arm32v7:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/kubedge -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.arm32v7 -t ${IMG_ARM32V7}
	docker tag ${IMG_ARM32V7} ${DHUBREPO_ARM32V7}:latest

docker-build-arm64v8:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/kubedge -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./cmd/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.arm64v8 -t ${IMG_ARM64V8}
	docker tag ${IMG_ARM64V8} ${DHUBREPO_ARM64V8}:latest

PLATFORMS ?= linux/arm64,linux/amd64,linux/arm/v7
.PHONY: docker-buildx
docker-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.buildkit > Dockerfile.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${IMG} --tag ${DHUBREPO}:latest -f Dockerfile.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.cross


# Push the docker image
docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8

docker-push-dev:
	docker push ${IMG_DEV}

docker-push-amd64:
	docker push ${IMG_AMD64}

docker-push-arm32v7:
	docker push ${IMG_ARM32V7}

docker-push-arm64v8:
	docker push ${IMG_ARM64V8}

# Run against the configured Kubernetes cluster in ~/.kube/config
install: install-dev

install-dev:
	cd charts/kubedge && helm install kubedge --values values.yaml --values values-dev.yaml .

install-amd64:
	cd charts/kubedge && helm install kubedge --values values.yaml --values values-amd64.yaml .

install-arm32v7:
	cd charts/kubedge && helm install kubedge --values values.yaml --values values-arm32v7.yaml .

install-arm64v8:
	cd charts/kubedge && helm install kubedge --values values.yaml --values values-arm64v8.yaml .

purge: setup
	helm delete kubedge

# Build the docker image for cross-plaform support
CONTAINER_TOOL ?= docker
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec
