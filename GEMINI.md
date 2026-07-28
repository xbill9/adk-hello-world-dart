# Gemini Code Assistant Context

This document provides context for the Gemini Code Assistant to understand the project architecture, dependencies, endpoints, and workflows for development and debugging.

## Project Overview

`adk-hello-world-dart` is a **Dart & Flutter-based Model Context Protocol (MCP) and Agent Development Kit (ADK) sample server**. It uses `package:adk_dart`, `package:adk_mcp`, and `package:shelf` to expose MCP tools (such as `greet`) and ADK agents (`AdkGreetingAgent`) over **HTTP Server-Sent Events (SSE)**.

## Key Technologies & Dependencies

* **Language:** Dart 3.5+ / Flutter SDK
* **SDKs:** `package:adk_dart` (^2026.7.24) & `package:adk_mcp` (^2026.7.24)
* **Web Framework:** `package:shelf` (^1.4.1) & `package:shelf_router` (^1.1.4)
* **Utilities:** `package:uuid` (^4.5.1), `package:logging` (^1.3.0)
* **Build System:** Dart Pub, `Makefile`, Docker (multi-stage scratch)
* **Style Guide:** Effective Dart (enforced by `dart analyze`)

## Project Structure & Architecture

### Source Code (`lib/`)

* **`adk_hello_world_dart.dart`**: Library barrel file exporting core project components.
* **`src/config.dart`**: `Config` class containing constants for server name (`mcp-https-server`), version (`1.0.0`), default port (`8080`), SSE (`/sse`) and messages (`/messages`) endpoints, and tool name constants.
* **`src/logger.dart`**: Configures logging using `package:logging` with hierarchical output.
* **`src/tools.dart`**: Contains domain logic `formatGreeting`, MCP tool definition (`toolDefinition`), direct execution handler `executeGreet`, and ADK tool representation `greetFunctionTool` (`FunctionTool`).
* **`src/adk_agent.dart`**: Defines `AdkGreetingAgent.createAgent()` returning an `LlmAgent` populated with `greetFunctionTool`.
* **`src/session_service.dart`**: `SessionService` class managing in-memory MCP sessions over SSE streams. Implements JSON-RPC 2.0 dispatch for `initialize`, `notifications/initialized`, `ping`, `tools/list`, and `tools/call`.

### Executables (`bin/`)

* **`server.dart`**: Web application entry point. Sets up Shelf middleware (CORS handling), defines routing (`/`, `/health`, `/sse`, `/messages`), checks `PORT` environment variable, and binds the HTTP server.
* **`main.dart`**: CLI demonstration showing initialization of `AdkGreetingAgent`.

### Tests (`test/`)

* **`tools_test.dart`**: Unit tests verifying domain logic, tool parameters, and default fallbacks.
* **`server_test.dart`**: Integration tests asserting `/health` endpoint response and invalid session handling (400 Bad Request).

### Deployment & Tooling (`/`)

* **`Dockerfile`**: Multi-stage build (build stage using `dart:stable`, runtime stage using `scratch` container).
* **`cloudbuild.yaml`**: Google Cloud Build pipeline deploying to Cloud Run with `--max-instances 1` to preserve single-instance in-memory session semantics.
* **`Makefile`**: Standard build, run, test, lint, format, check, clean, and deployment recipes.
* **`test_mcp.py`**: Python script for end-to-end SSE connection & MCP protocol testing.

## Server Endpoints

- **`GET /`**: Returns `"ADK & MCP Dart Server Running"`.
- **`GET /health`**: Health check returning `"OK"`.
- **`GET /sse`**: Connects SSE client, assigns a random UUID `sessionId`, and emits an initial `endpoint` event containing `/messages?sessionId=<id>`.
- **`POST /messages`**: Accepts JSON-RPC 2.0 payloads for an active session (`sessionId` passed as query parameter).

## Development Setup & Workflows

1. **Install Dependencies & Compile Executable:**
   ```bash
   make build
   # or: dart pub get && dart compile exe bin/server.dart -o build/bin/server
   ```

2. **Run Server:**
   ```bash
   make run
   # or: dart run bin/server.dart
   ```

3. **Run Tests:**
   ```bash
   make test
   # or: dart test
   ```

4. **Static Analysis & Linting:**
   ```bash
   make lint
   # or: dart analyze
   ```

5. **Format Codebase:**
   ```bash
   make format
   # or: dart format .
   ```

6. **Full Validation:**
   ```bash
   make check
   ```

## Resources

* **ADK Dart Package:** [https://pub.dev/packages/adk_dart](https://pub.dev/packages/adk_dart)
* **ADK MCP Package:** [https://pub.dev/packages/adk_mcp](https://pub.dev/packages/adk_mcp)
* **MCP Specification:** [https://modelcontextprotocol.io](https://modelcontextprotocol.io)

