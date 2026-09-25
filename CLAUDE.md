# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A from-scratch build of a self-hosted LLM server on one consumer GPU, in three phases:

1. **Chat** – serve a quantized open-weight model behind an OpenAI-compatible HTTP API and chat with it.
2. **Tools** – add tool/function calling to the chat loop.
3. **Agentic coding** – use the local model as the backend for a coding agent.

Nothing is built yet beyond this scaffold. Update this file as the phases land.

## Target environment (verified 2026-09-25)

- GPU: NVIDIA GeForce RTX 3060, 12 GB VRAM (Ampere). This is the hard budget: model weights + KV cache
  must fit in ~11 GB after CUDA overhead.
- OS: Windows 11, native. **No WSL2 and no Docker are installed.** Anything that only ships Linux builds
  (notably vLLM) cannot run here without first installing WSL2.
- Node.js 26 and npm 11 are on PATH (Bun 1.3 is also installed but is not used). Node 26 runs `.ts`
  files directly via built-in type stripping, so there is no build step in development.
- Shell: PowerShell is primary; a Git Bash is also available.

## Language: pure TypeScript

All code in this repo is TypeScript, running on Node.js. This is a deliberate choice: the owner is
learning TypeScript through this project. Prefer explaining *why* a TypeScript construct is used
over just writing it, and prefer idiomatic, strict, well-typed code over clever shortcuts.

- Strict mode on (`"strict": true` in `tsconfig.json`), ESM modules (`"type": "module"`).
- Use `.ts` extensions in relative imports so Node can run the source directly.
- The inference engine is C++ (llama.cpp) and is never linked or wrapped in-process. It is only
  ever reached over HTTP.

## Architecture decision: backend-agnostic, OpenAI-compatible

The inference engine is treated as a swappable component. All application code (chat CLI, tool
runner, agent) talks **only** to an OpenAI-compatible `/v1/chat/completions` endpoint, using the
official `openai` npm package pointed at the local base URL. This keeps the door open to move from a native Windows
engine (llama.cpp / Ollama) to vLLM under WSL2 later without touching the client side.

Engine order of preference for this hardware:

1. `llama-server` from llama.cpp (native Windows CUDA build, GGUF quants, `--jinja` for tool calling).
2. Ollama (wraps llama.cpp, easier model management, same OpenAI-compatible surface).
3. vLLM under WSL2 – only if throughput or multi-client serving becomes the bottleneck.

Model weights (`models/`, `*.gguf`, `*.safetensors`) are git-ignored and must never be committed.

## Conventions

- Keep engine-specific launch flags in scripts under `scripts/`, not in application code.
- Keep the server base URL and model name in configuration (env vars / `.env`), not hard-coded.
- Any new phase gets a short section in this file: how to start the server, how to run the client,
  which model was validated and at which quant.

## Commands

None yet. Add build/run/test commands here as they are created.
