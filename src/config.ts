// Reads runtime configuration from environment variables, with defaults that
// match the llama-server defaults (127.0.0.1:8080). Keeping this in one place
// means no other file hard-codes a URL or model name.

export interface LlmConfig {
  readonly baseURL: string;
  readonly model: string;
}

export function loadConfig(env: NodeJS.ProcessEnv = process.env): LlmConfig {
  return {
    baseURL: env.LLM_BASE_URL ?? "http://127.0.0.1:8080/v1",
    model: env.LLM_MODEL ?? "local",
  };
}
