
compose-start:
	@echo "Building images..."
	@docker compose build
	@echo "Starting docker compose..."
	@docker compose up -d

compose-stop:
	@echo "Stopping docker compose..."
	@docker compose down