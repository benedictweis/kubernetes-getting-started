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

all: kind-up apply-manifests restart-deployments open-url

kind-up: create-kind-cluster build-images load-images retrive-kubeconfig

kind-down: delete-kind-cluster

build-images:
	@echo "Building images..."
	docker build -t $(FRONTEND_IMAGE_NAME) -f $(FRONTEND)/Dockerfile $(FRONTEND)
	docker build -t $(BACKEND_IMAGE_NAME) -f $(BACKEND)/Dockerfile $(BACKEND)

create-kind-cluster:
	@echo "Creating kind cluster"
	kind create cluster --config $(KIND_CLUSTER_CONFIG) || echo "Warning: kind cluster is already present"

delete-kind-cluster:
	@echo "Deleting kind cluster"
	kind delete cluster --name $(KIND_CLUSTER_NAME)

load-images:
	@echo "Loading images into kind cluster"
	kind load docker-image $(FRONTEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)
	kind load docker-image $(BACKEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)

retrive-kubeconfig:
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
