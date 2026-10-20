# Starts a second llama-server that only computes embeddings, for retrieval (RAG) in the chat app.
# It runs beside the chat server from start-server.ps1, on its own port, and answers the
# OpenAI-compatible POST /v1/embeddings. Flags follow tools/server/README.md in ggml-org/llama.cpp.
#
#   --embedding      serve embeddings only (no chat completions)
#   --pooling mean   one vector per input, averaged over its tokens (what nomic-embed and bge-m3 use)
#   -c / -np         total context split over parallel slots: 8192 / 4 = 2048 tokens per input,
#                    nomic-embed-text-v1.5's trained context. RAG chunks are ~400 tokens.
#   -b / -ub         an embedding input must fit in one micro-batch, so both match the slot size
#   -ngl all         the model is small (~150 MB at Q8_0), so it costs ~0.3 GB of VRAM next to the
#                    chat model. Pass -Ngl 0 to keep it on the CPU when VRAM is tight.
#
# Usage:  .\scripts\start-embeddings.ps1 [-Model <repo:quant | path.gguf>] [-Port 8081] [-Ngl all]
#
# Changing the model changes the vector size (nomic 768, bge-m3 1024): vectors already stored by
# the RAG API must then be deleted and the files uploaded again.

param(
  [string]$Model = "nomic-ai/nomic-embed-text-v1.5-GGUF:Q8_0",
  [int]$Port = 8081,
  [string]$Ngl = "all"
)

$llama = Join-Path $PSScriptRoot "..\bin\llama-server.exe"
if (-not (Test-Path $llama)) {
  Write-Error "llama-server.exe not found at $llama. See CLAUDE.md for install steps."
  exit 1
}

# -hf downloads into the llama.cpp cache (LLAMA_CACHE) if not already present.
$modelArgs = if ($Model -like "*.gguf") { @("-m", $Model) } else { @("-hf", $Model) }

& $llama @modelArgs `
  --embedding `
  --pooling mean `
  -c 8192 -np 4 `
  -b 2048 -ub 2048 `
  -ngl $Ngl `
  --host 127.0.0.1 `
  --port $Port `
  --alias embed
