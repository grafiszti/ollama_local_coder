up:
	docker compose build
	docker compose up -d

down:
	docker compose down

validate:
	curl http://localhost:11434/api/tags

setup_ollama:
	docker exec -it ollama ollama pull deepseek-coder:6.7b
	docker exec -it ollama ollama pull deepseek-coder:1.3b

check-gpu:
	@echo "Checking GPU setup..."
	@if command -v nvidia-smi > /dev/null 2>&1; then \
		echo "✓ NVIDIA driver is installed"; \
		nvidia-smi --query-gpu=name,driver_version --format=csv,noheader | head -1; \
	else \
		echo "✗ NVIDIA driver not found"; \
	fi
	@if docker info 2>/dev/null | grep -q "nvidia"; then \
		echo "✓ NVIDIA runtime is configured in Docker"; \
	else \
		echo "✗ NVIDIA runtime not configured in Docker"; \
		echo ""; \
		echo "To install NVIDIA Container Toolkit:"; \
		echo "  Visit: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"; \
		echo "  Or run: curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"; \
		echo "         curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"; \
		echo "         sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"; \
		echo "         sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker"; \
	fi
