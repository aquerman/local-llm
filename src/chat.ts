// Phase 1: a minimal streaming chat REPL against a local OpenAI-compatible server.
//
// Run with:  npm run chat        (Node 22.18+ strips the types at load time)
// Type-check: npm run typecheck  (tsc, no output files)

import { createInterface } from "node:readline/promises";
import { stdin, stdout } from "node:process";
import OpenAI from "openai";
import type { ChatCompletionMessageParam } from "openai/resources/chat/completions";
import { loadConfig } from "./config.ts";

const config = loadConfig();

// llama-server ignores the API key, but the SDK requires a non-empty string.
const client = new OpenAI({ baseURL: config.baseURL, apiKey: "not-needed" });

// The full conversation so far. The server is stateless: we resend every turn.
const messages: ChatCompletionMessageParam[] = [
  { role: "system", content: "You are a helpful assistant running locally." },
];

async function ask(userText: string): Promise<void> {
  messages.push({ role: "user", content: userText });

  const stream = await client.chat.completions.create({
    model: config.model,
    messages,
    stream: true,
  });

  let reply = "";
  for await (const chunk of stream) {
    const delta = chunk.choices[0]?.delta?.content ?? "";
    stdout.write(delta);
    reply += delta;
  }
  stdout.write("\n");

  messages.push({ role: "assistant", content: reply });
}

const rl = createInterface({ input: stdin, output: stdout });
console.log(`Connected to ${config.baseURL} (model: ${config.model}). Ctrl+C to quit.
`);

// readline is an async iterable of lines. Iterating it (instead of calling
// rl.question() in a loop) means lines that arrive while we are awaiting a
// reply are queued rather than lost, and the loop ends cleanly when stdin
// closes (Ctrl+D, or the end of piped input) after the last reply finishes.
// Once stdin has closed, prompt() throws ERR_USE_AFTER_CLOSE, but the iterator
// may still hand us lines that were buffered before the close. Track it.
let inputClosed = false;
rl.once("close", () => { inputClosed = true; });

rl.setPrompt("you> ");
rl.prompt();
for await (const line of rl) {
  if (line.trim() !== "") {
    stdout.write("llm> ");
    await ask(line);
  }
  if (!inputClosed) rl.prompt();
}
