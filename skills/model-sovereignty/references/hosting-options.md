# Hosting Options for Local and Custom Models

## Quick Comparison

| Option | Best for | Throughput | Complexity | GPU required |
| --- | --- | --- | --- | --- |
| Ollama | Individual/small team, development | Moderate | Low | Optional (CPU viable for small models) |
| vLLM | Production serving, high concurrency | High | Medium | Yes |
| llama.cpp | Embedded, edge, maximum control | Varies | High | Optional |
| Cloud private | Managed compliance, no hardware | High | Low | No (managed) |

## Ollama

**What:** CLI and server wrapping llama.cpp with OpenAI-compatible API.
**Install:** `curl -fsSL https://ollama.com/install.sh | sh`
**Run a model:** `ollama run qwen2.5-coder:32b`
**Serve for API access:** `ollama serve` (default port 11434)
**Hot-swap:** Automatically unloads old model, loads new one.
**Tool calling:** Supported natively (2026).

**When to use:** Development, experimentation, single-developer or
small-team inference. The "just works" option for getting started.

## vLLM

**What:** Production inference engine with PagedAttention for high
throughput under concurrent load.
**Install:** `pip install vllm`
**Serve:** `vllm serve <model-name> --port 8000`
**Performance:** ~485 tok/s for 8B models under 10 concurrent requests.

**When to use:** Production serving where multiple users or agents
hit the model concurrently. The standard for internal API deployment.

## llama.cpp

**What:** C++ inference engine. Foundation technology for Ollama and
others. Compiles to native binaries for any platform.
**When to use:** When you need native iOS/Android/WebAssembly
deployment, custom compilation flags, or absolute minimum footprint.
Not recommended as a starting point — use Ollama unless you need
llama.cpp's specific capabilities.

## Cloud Private Endpoints

**What:** Managed model hosting with data residency guarantees.
Providers include Azure OpenAI, AWS Bedrock, Google Vertex AI.
**When to use:** When regulatory compliance requires data residency
but you do not want to manage GPU infrastructure. The middle ground
between full self-hosting and public cloud APIs.

## Cost Break-Even

Self-hosted GPU inference breaks even against cloud API pricing at
approximately 30M tokens/day sustained usage, within 4 months of
hardware investment. Below that threshold, cloud APIs are cheaper.
Above it, self-hosted becomes progressively more economical.

Factors that shift the break-even:

- Electricity costs (significant for 24/7 GPU operation)
- Hardware utilisation (idle GPUs are waste)
- Maintenance labour (someone must manage the infrastructure)
- Model size (larger models require more expensive hardware)
