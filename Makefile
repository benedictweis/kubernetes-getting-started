FRONTEND_IMAGE_NAME=word-app-frontend
FRONTEND=./frontend

BACKEND_IMAGE_NAME=word-app-service
BACKEND=./backend

KIND_CLUSTER_CONFIG=./kind-config.yaml
KIND_CLUSTER_NAME=$(shell yq '.name' $(KIND_CLUSTER_CONFIG))
KIND_KUBECONFIG=kind-kubeconfig.yaml

MANIFESTS=./manifests
FRONTEND_DEPLOYMENT=./manifests/frontend.yaml
BACKEND_DEPLOYMENT=./manifests/backend.yaml

EXPOSED_URL=http://localhost:$(shell yq '.nodes.[0].extraPortMappings.[0].hostPort' $(KIND_CLUSTER_CONFIG))

#######################################
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/#
#   DOCKER   +   KIND   +   KUBECTL   #
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\#
#######################################

all: kind-up apply-manifests open-url

kind-up: create-kind-cluster kind-images

kind-images: build-images load-images retrieve-kubeconfig

kind-down: delete-kind-cluster

create-kind-cluster:
	@echo "Creating kind cluster"
	kind create cluster --config $(KIND_CLUSTER_CONFIG) || echo "Warning: kind cluster is already present"

build-images:
	@echo "Building images..."
	docker build -t $(FRONTEND_IMAGE_NAME) -f $(FRONTEND)/Dockerfile $(FRONTEND)
	docker build -t $(BACKEND_IMAGE_NAME) -f $(BACKEND)/Dockerfile $(BACKEND)

delete-kind-cluster:
	@echo "Deleting kind cluster"
	kind delete cluster --name $(KIND_CLUSTER_NAME)

load-images:
	@echo "Loading images into kind cluster"
	kind load docker-image $(FRONTEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)
	kind load docker-image $(BACKEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)

retrieve-kubeconfig:
	@echo "Retriving kubeconfig"
	kind get kubeconfig --name $(KIND_CLUSTER_NAME) > $(KIND_KUBECONFIG)
	@echo "To load the kubeconfig type export KUBECONFIG=\$$PWD/$(KIND_KUBECONFIG)"

apply-manifests: 
	@echo "Applying manifests..."
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f $(MANIFESTS)

restart-deployments:
	@echo "Applying deployments to cluster..."
	kubectl rollout --kubeconfig $(KIND_KUBECONFIG) restart -f $(FRONTEND_DEPLOYMENT) | echo "Warning: restarting deployments failed"
	kubectl rollout --kubeconfig $(KIND_KUBECONFIG) restart -f $(BACKEND_DEPLOYMENT) | echo "Warning: restarting deployments failed"

open-url:
	@xdg-open $(EXPOSED_URL) &> /dev/null || open $(EXPOSED_URL) &> /dev/null

#############################
#/\/\/\/\/\/\/\/\/\/\/\/\/\/#
#   KUSTOMIZE   +   CADDY   #
#\/\/\/\/\/\/\/\/\/\/\/\/\/\#
#############################

KUSTOMIZATION=./kustomization/overlays/prod
KIND_CLUSTER_CONFIG_KUSTOMIZE=./kind-config-kustomize.yaml

kustomize/all: kustomize/kind-up kustomize

kustomize/kind-up: kustomize/create-kind-cluster kind-images

kustomize/create-kind-cluster:
	@echo "Creating kind cluster for kustomize setup"
	kind create cluster --config $(KIND_CLUSTER_CONFIG_KUSTOMIZE) || echo "Warning: kind cluster is already present"

kustomize:
	@echo "Applying Kustomization..."
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -k $(KUSTOMIZATION)
