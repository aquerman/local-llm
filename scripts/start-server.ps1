# Starts llama-server with the flags used for this project.
# Flags follow tools/server/README.md and docs/function-calling.md in ggml-org/llama.cpp.
#
#   --jinja   required for OpenAI-style tool calling (uses the model's chat template)
#   -fa on    flash attention
#   -ngl all  put every layer on the GPU
#   -c        context size in tokens (0 would mean "read from model", 262k for Qwen3.5).
#             131072 fits Qwen3.5-9B: only 8 of its 32 layers keep a KV cache (the rest are
#             Gated DeltaNet), so 128k at q8_0 is roughly 2 GB on top of the weights.
#   -ctk/-ctv q8_0 KV cache: halves KV memory vs f16 with negligible quality loss.
#             (docs warn that *extreme* KV quantization hurts tool calling; q8_0 is not extreme)
#   --reasoning-budget-message  text injected when a per-request thinking budget runs out
#
# Usage:  .\scripts\start-server.ps1 [-Model <repo:quant | path.gguf>] [-Ctx 131072]

param(
  [string]$Model = "unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL",
  [int]$Ctx = 131072,
  [int]$Port = 8080,
  [string]$Name = "Benner"
)

$llama = Join-Path $PSScriptRoot "..\bin\llama-server.exe"
if (-not (Test-Path $llama)) {
  Write-Error "llama-server.exe not found at $llama. See CLAUDE.md for install steps."
  exit 1
}

# -hf downloads into the llama.cpp cache (LLAMA_CACHE) if not already present.
$modelArgs = if ($Model -like "*.gguf") { @("-m", $Model) } else { @("-hf", $Model) }

# The name clients see in /v1/models (LibreChat fetches it): "Benner (<model>)".
# "unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL" -> "Qwen3.5-9B"; "C:\m\foo.gguf" -> "foo".
$shortName = if ($Model -like "*.gguf") {
  [IO.Path]::GetFileNameWithoutExtension($Model)
} else {
  (($Model -split ":")[0] -split "/")[-1] -replace "-GGUF$", ""
}
$alias = "$Name ($shortName)"
Write-Host "Serving $Model as `"$alias`""

& $llama @modelArgs `
  --jinja `
  -fa on `
  -ngl all `
  -c $Ctx `
  -ctk q8_0 -ctv q8_0 `
  --reasoning-budget-message "Okay, I have thought enough. Time to answer." `
  --port $Port `
  --alias $alias
