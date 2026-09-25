# local-llm

A step-by-step build of a self-hosted LLM server on a single consumer NVIDIA GPU, with the goal of
reaching parity with hosted chat assistants and then using it for agentic coding.

## Roadmap

1. **Chat** – serve a quantized open-weight model locally behind an OpenAI-compatible HTTP API and chat with it.
2. **Tools** – add tool/function calling (web search, file access, code execution, etc.) on top of the chat loop.
3. **Agentic coding** – use the local model as the backend for a coding agent.

## Hardware

- NVIDIA GeForce RTX 3060, 12 GB VRAM
- Windows 11 (native, no WSL2 at the moment)

## Status

Just started. See `CLAUDE.md` for the architecture decisions and conventions.
