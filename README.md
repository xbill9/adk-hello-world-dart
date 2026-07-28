# ADK & MCP Hello World for Dart & Flutter

A Dart and Flutter-based Model Context Protocol (MCP) and Agent Development Kit (ADK) sample server using official `package:adk_dart` and `package:adk_mcp` with **`package:shelf`**. This server communicates over **HTTP Server-Sent Events (SSE)** and serves as a production-grade reference implementation for Dart & Flutter AI agent integrations.

## Overview

This repository provides a Dart server (`adk-hello-world-dart`) exposing an MCP tool (`greet`) and an ADK agent (`AdkGreetingAgent`). It uses `package:shelf` and `package:shelf_router` for the web layer, managing MCP session transport over SSE and JSON-RPC 2.0 message processing.

> [!IMPORTANT]
> This demo stores active MCP session transports in memory. When deploying to container environments like Google Cloud Run, set concurrency/instance constraints (`--max-instances 1`) unless session management is backed by an external store.

## Key Technologies

* **Language:** Dart 3.5+ / Flutter SDK
* **Agent & MCP SDKs:** `package:adk_dart` (^2026.7.24) & `package:adk_mcp` (^2026.7.24)
* **Web Framework:** `package:shelf` (^1.4.1) & `package:shelf_router` (^1.1.4)
* **Utilities:** `package:uuid`, `package:logging`
* **Package Manager:** Dart Pub

## Prerequisites

- **Dart SDK 3.5+** or **Flutter SDK**
- *(Optional)* **Docker** for containerized execution
- *(Optional)* **Google Cloud SDK (`gcloud`)** for Cloud Run deployment

## Quick Start

### 1. Install Dependencies
```bash
make build
# Or manually:
dart pub get
```

### 2. Run the Server
```bash
make run
# Or manually:
dart run bin/server.dart
# Or using the run script:
./run.sh
```

By default, the server runs on port `8080` (configurable via `PORT` environment variable).

## Endpoints

| Method | Route | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Root endpoint returning server status banner. |
| `GET` | `/health` | Health check endpoint returning `OK` (200). |
| `GET` | `/sse` | Establishes SSE stream connection & returns `endpoint` URI for messages. |
| `POST` | `/messages` | Receives MCP JSON-RPC 2.0 requests (requires `?sessionId=<id>`). |

## Supported MCP Protocol Methods

The server implements JSON-RPC 2.0 over SSE according to the MCP specification:
- `initialize` — Handshakes and advertises server capabilities and metadata.
- `notifications/initialized` — Processes client initialization notifications.
- `ping` — Connection keep-alive check.
- `tools/list` — Advertises available tools (`greet`).
- `tools/call` — Executes requested tool (`greet`) with supplied arguments.

## Project Structure

```
.
├── bin/
│   ├── main.dart             # CLI demonstration for ADK Agent initialization
│   └── server.dart           # Web server entry point (Shelf, CORS, routes)
├── lib/
│   ├── adk_hello_world_dart.dart # Barrel export file
│   └── src/
│       ├── adk_agent.dart    # AdkGreetingAgent definition using LlmAgent
│       ├── config.dart       # Centralized configuration (server info, routes, tool names)
│       ├── logger.dart       # Logging setup using package:logging
│       ├── session_service.dart # MCP SSE session transport & RPC dispatcher
│       └── tools.dart        # Domain logic, MCP tool schema, & ADK FunctionTool
├── test/
│   ├── server_test.dart      # Integration tests for server endpoints & routing
│   └── tools_test.dart       # Unit tests for tools and formatting logic
├── Dockerfile                # Multi-stage Docker build producing a minimal scratch container
├── cloudbuild.yaml           # Google Cloud Build build and Cloud Run deployment pipeline
├── Makefile                  # Helper commands for build, run, test, lint, format, and deploy
└── test_mcp.py               # Python test script for validating SSE/MCP handshake & tools
```

## Development & Makefile Commands

- **Build / Dependencies:** `make build` (installs pub dependencies & compiles native executable to `build/bin/server`)
- **Run Server:** `make run`
- **Run Tests:** `make test`
- **Run Linter:** `make lint` (`dart analyze`)
- **Format Code:** `make format` (`dart format .`)
- **Full Verification:** `make check` (runs build, lint, and test)
- **Clean Build Artifacts:** `make clean`
- **Cloud Run Deployment:** `make deploy`

## MCP Client Configuration

To connect an MCP client (e.g. Claude Desktop, VS Code extensions, or custom MCP hosts) to this server over SSE, specify the SSE URL in your client configuration:

```json
{
  "mcpServers": {
    "dart-mcp-server": {
      "url": "http://localhost:8080/sse"
    }
  }
}
```

*Note: Ensure the Dart server is running prior to connecting from your MCP client.*

## Tools Reference

### `greet`
- **Name:** `greet`
- **Description:** Get a greeting from a local HTTPS server.
- **Parameters:**
  - `param` (string, required): The name to greet. Defaults to `"World"` if omitted.
- **Returns:** Text content containing formatted greeting string `Hello, <param>!`.

## Deployment

### Docker
To build and run locally with Docker:
```bash
docker build -t adk-hello-world-dart .
docker run -p 8080:8080 adk-hello-world-dart
```

### Google Cloud Run
Deploy using Google Cloud Build:
```bash
make deploy
```
*Configured via `cloudbuild.yaml` to deploy to Cloud Run with `--max-instances 1` for single-instance session handling.*

## Resources

- [ADK Dart Package (pub.dev)](https://pub.dev/packages/adk_dart)
- [ADK MCP Package (pub.dev)](https://pub.dev/packages/adk_mcp)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)

