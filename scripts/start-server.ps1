# Starts llama-server with the flags used for this project.
# Flags follow tools/server/README.md and docs/function-calling.md in ggml-org/llama.cpp.
#
#   --jinja   required for OpenAI-style tool calling (uses the model's chat template)
#   -fa on    flash attention
#   -ngl all  put every layer on the GPU
#   -c        context size in tokens (0 would mean "read from model", which is 32k+ for Qwen)
#   -ctk/-ctv q8_0 KV cache: halves KV memory vs f16 with negligible quality loss.
#             (docs warn that *extreme* KV quantization hurts tool calling; q8_0 is not extreme)
#
# Usage:  .\scripts\start-server.ps1 [-Model <repo:quant | path.gguf>] [-Ctx 16384]

param(
  [string]$Model = "bartowski/Qwen2.5-7B-Instruct-GGUF:Q4_K_M",
  [int]$Ctx = 16384,
  [int]$Port = 8080
)

$llama = Join-Path $PSScriptRoot "..\bin\llama-server.exe"
if (-not (Test-Path $llama)) {
  Write-Error "llama-server.exe not found at $llama. See CLAUDE.md for install steps."
  exit 1
}

# -hf downloads into the llama.cpp cache (LLAMA_CACHE) if not already present.
$modelArgs = if ($Model -like "*.gguf") { @("-m", $Model) } else { @("-hf", $Model) }

& $llama @modelArgs `
  --jinja `
  -fa on `
  -ngl all `
  -c $Ctx `
  -ctk q8_0 -ctv q8_0 `
  --port $Port `
  --alias local
