# local-llm

A step-by-step build of a self-hosted LLM server on a single consumer NVIDIA GPU, with the goal of
reaching parity with hosted chat assistants and then using it for agentic coding.

## Roadmap

1. **Chat** – serve a quantized open-weight model locally behind an OpenAI-compatible HTTP API and chat with it.
2. **Tools** – add tool/function calling (web search, file access, code execution, etc.) on top of the chat loop.
3. **Agentic coding** – use the local model as the backend for a coding agent.

## Stack

- Client, tools and agent: TypeScript on Node.js 26
- Inference engine: llama.cpp `llama-server`, reached over its OpenAI-compatible HTTP API

## Hardware

- NVIDIA GeForce RTX 3060, 12 GB VRAM
- Windows 11 (native, no WSL2 at the moment)

## Status

Phase 1 works: `npm run chat` streams replies from Qwen2.5-7B-Instruct served by llama-server on
the GPU. See `CLAUDE.md` for setup, architecture decisions and conventions.
