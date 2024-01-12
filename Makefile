
FRONTEND_IMAGE_NAME=word-app-frontend
FRONTEND_FOLDER=./frontend
FRONTEND_DOCKERFILE=./frontend/Dockerfile

BACKEND_IMAGE_NAME=word-app-service
BACKEND_FOLDER=./backend
BACKEND_DOCKERFILE=./backend/Dockerfile

KIND_CLUSTER_CONFIG=./kind-config.yaml
KIND_CLUSTER_NAME=word-app-demo
KIND_KUBECONFIG=kind-kubeconfig.yaml

CONFIGMAP=./deployments/configmap.yaml
FRONTEND_DEPLOYMENT=./deployments/frontend.yaml
BACKEND_DEPLOYMENT=./deployments/backend.yaml

# Docker Compose setup

compose-start: compose-build
	@echo "Starting docker compose..."
	@docker compose up -d

compose-start-attach: compose-build
	@echo "Starting docker compose..."
	@docker compose up

compose-build:
	@echo "Building images for compose..."
	@docker compose build

compose-stop:
	@echo "Stopping docker compose..."
	@docker compose down

# Kind setup

kind-up: create-kind-cluster build-images load-images retrive-kubeconfig

kind-down: delete-kind-cluster

build-images:
	@echo "Building images..."
	docker build -t $(FRONTEND_IMAGE_NAME) -f $(FRONTEND_DOCKERFILE) $(FRONTEND_FOLDER)
	docker build -t $(BACKEND_IMAGE_NAME) -f $(BACKEND_DOCKERFILE) $(BACKEND_FOLDER)

create-kind-cluster:
	@echo "Creating kind cluster"
	kind create cluster --config $(KIND_CLUSTER_CONFIG)

delete-kind-cluster:
	@echo "Deleting kind cluster"
	kind delete cluster --name $(KIND_CLUSTER_NAME)

load-images:
	@echo "Loading images into kind cluster"
	kind load docker-image $(FRONTEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)
	kind load docker-image $(BACKEND_IMAGE_NAME) --name $(KIND_CLUSTER_NAME)

# To load the kubeconfig type `export KUBECONFIG=${PWD}/<path_to_kubeconfig>`
retrive-kubeconfig:
	@echo "Retriving kubeconfig"
	kind get kubeconfig --name $(KIND_CLUSTER_NAME) > $(KIND_KUBECONFIG)

apply-configmap:
	@echo "Applying configmap to cluster..."
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f $(CONFIGMAP)

apply-deployments:
	@echo "Applying deployments to cluster..."
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f $(FRONTEND_DEPLOYMENT) 
	kubectl apply --kubeconfig $(KIND_KUBECONFIG) -f $(BACKEND_DEPLOYMENT)
