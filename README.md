# Ollama Coder
A Docker-based setup for running Ollama locally with GPU acceleration, optimized for use as a local LLM provider in Cursor IDE.

## Features
- 🚀 **GPU Acceleration**: Configured for NVIDIA GPUs with optimized settings
- 🐳 **Docker Compose**: Easy setup and management
- 💻 **Cursor Integration**: Ready to use as a local LLM in Cursor
- ⚡ **Optimized Performance**: Pre-configured with flash attention and GPU tuning
- 🔧 **Simple Management**: Makefile commands for common tasks

## Prerequisites
- Docker and Docker Compose installed
- NVIDIA GPU with drivers installed
- NVIDIA Container Toolkit (for GPU support)

## Quick Start
### 1. Check GPU Setup

First, verify your GPU setup:
```bash
make check-gpu
```
If the NVIDIA runtime is not configured, follow the installation instructions shown, or visit the [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html).

### 2. Start Ollama
This will start the Ollama container in the background.
```bash
make up
```

### 3. Download Models
Download the DeepSeek Coder models:
```bash
make setup_ollama
```

This will download:
- `deepseek-coder:6.7b` - Larger, more capable model
- `deepseek-coder:1.3b` - Smaller, faster model
### 4. Verify Installation
Check that Ollama is running and models are available:
```bash
make validate
```
## Configuration
### GPU Settings
The docker-compose.yml is pre-configured with:
- `OLLAMA_NUM_GPU=1`: Use 1 GPU
- `OLLAMA_GPU_LAYERS=35`: Number of layers to run on GPU
- `OLLAMA_NUM_PARALLEL=2`: Parallel request handling
- `OLLAMA_FLASH_ATTENTION=1`: Enable flash attention for better performance
- `OLLAMA_KEEP_ALIVE=24h`: Keep models loaded in VRAM for 24 hours

You can adjust these settings in `docker-compose.yml` based on your GPU memory and requirements.

### Cursor Integration

To use this Ollama instance with Cursor:

1. Open Cursor Settings
2. Navigate to **Features** → **AI** → **Local Models**
3. Add a new local model provider:
   - **Base URL**: `http://localhost:11434`
   - **Model**: `deepseek-coder:6.7b` or `deepseek-coder:1.3b`
4. Select the model as your AI provider

## Makefile Commands

| Command | Description |
|---------|-------------| 
| `make up` | Start the Ollama container |
| `make validate` | Check if Ollama is running and list available models |
| `make setup_ollama` | Download DeepSeek Coder models (6.7b and 1.3b) |
| `make check-gpu` | Verify GPU setup and NVIDIA runtime configuration |

## Manual Docker Commands

If you prefer using Docker Compose directly:

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f ollama

# Pull additional models
docker exec -it ollama ollama pull <model-name>

# List available models
docker exec -it ollama ollama list
```

## Troubleshooting

### GPU Not Detected

If GPU acceleration isn't working:

1. Verify NVIDIA drivers are installed:
   ```bash
   nvidia-smi
   ```

2. Check NVIDIA Container Toolkit installation:
   ```bash
   make check-gpu
   ```

3. Restart Docker after installing the toolkit:
   ```bash
   sudo systemctl restart docker
   ```

### Port Already in Use

If port 11434 is already in use, modify the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "11435:11434"  # Change 11434 to your preferred port
```

Don't forget to update the Cursor configuration with the new port.

### Out of Memory

If you encounter OOM errors:

- Reduce `OLLAMA_GPU_LAYERS` in `docker-compose.yml`
- Use the smaller model (`deepseek-coder:1.3b`) instead
- Reduce `OLLAMA_NUM_PARALLEL` to 1

## Model Recommendations

- **deepseek-coder:6.7b**: Best for complex code generation, requires ~8GB VRAM
- **deepseek-coder:1.3b**: Faster, lighter option, requires ~2GB VRAM

Choose based on your GPU memory and performance needs.

## Data Persistence

Model data is stored in a Docker volume (`ollama_data`), so your downloaded models persist across container restarts. To remove all data:

```bash
docker compose down -v
```

## License

This project is a setup configuration for Ollama. Please refer to:
- [Ollama License](https://github.com/ollama/ollama/blob/main/LICENSE)
- [DeepSeek Coder License](https://github.com/deepseek-ai/DeepSeek-Coder)

## Acknowledgments

- [Ollama](https://ollama.ai/) - The LLM runtime
- [DeepSeek](https://www.deepseek.com/) - The DeepSeek Coder models
- [Cursor](https://cursor.sh/) - The AI-powered code editor

