import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const SEARXNG_URL = process.env.SEARXNG_URL || "http://searxng:8080";

const server = new Server(
  { name: "searxng-search", version: "1.0.0" },
  { capabilities: { tools: {} } },
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "search",
      description: "Search the web using SearXNG metasearch engine",
      inputSchema: {
        type: "object",
        properties: {
          query: { type: "string", description: "Search query" },
          categories: {
            type: "string",
            description: "Search category (general, news, science, images, videos, etc.)",
          },
          language: {
            type: "string",
            description: "Language code (en, fr, de, pl, etc.)",
          },
        },
        required: ["query"],
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name !== "search") {
    throw new Error(`Unknown tool: ${request.params.name}`);
  }

  const { query, categories = "general", language = "all" } = request.params.arguments;
  const params = new URLSearchParams({ q: query, format: "json", categories, language });
  const url = `${SEARXNG_URL}/search?${params}`;

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`SearXNG returned ${response.status}`);
  }
  const data = await response.json();

  const snippets = (data.results || []).slice(0, 10).map((r, i) =>
    `${i + 1}. [${r.title}](${r.url})\n   ${(r.content || "").slice(0, 300)}`
  ).join("\n\n");

  return { content: [{ type: "text", text: snippets || "No results found." }] };
});

const transport = new StdioServerTransport();
await server.connect(transport);
