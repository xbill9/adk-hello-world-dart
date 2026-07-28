# Building AI Agents with the Dart ADK & Model Context Protocol (MCP)

This repository provides a sample scaffolding for building AI agent services and Model Context Protocol (MCP) servers using Dart 3.12, `adk_dart`, `adk_mcp`, and `shelf`.

## Overview

The Dart ADK & MCP sample project demonstrates how to structure Dart/Flutter applications for agentic integration:
- **Server Architecture**: Built with `shelf` exposing Server-Sent Events (SSE) and HTTP message POST endpoints.
- **Protocol**: Implements the Model Context Protocol (MCP) via `adk_mcp` and custom session routing.
- **Tooling**: Modular tool registration system (`Tools`) wrapping ADK `FunctionTool` for defining capabilities, JSON schemas, and execution handlers.
- **Agent Framework**: Uses `adk_dart` (`LlmAgent`, `FunctionTool`, `AdkGreetingAgent`).

## Key Components

### 1. Application Entry Point (`bin/server.dart`)
Sets up Shelf middleware and routes:
- CORS middleware for cross-origin handling.
- `SSE` for real-time bi-directional transport (`/sse`).
- Message endpoint (`/messages`) for processing MCP JSON-RPC requests.

### 2. Session Management (`lib/src/session_service.dart`)
Manages active SSE client sessions and message routing between HTTP endpoints and active streams.

### 3. Tool Registration (`lib/src/tools.dart`)
Defines tools (such as `greet`) with structured schemas, argument extraction, logging, and testable domain logic handlers (`formatGreeting`). Also provides `greetFunctionTool` for ADK agents.

### 4. ADK Agent Integration (`lib/src/adk_agent.dart`)
Creates an `LlmAgent` using `adk_dart` configured with instructions and registered ADK function tools.

### 5. Configuration (`lib/src/config.dart`)
Centralized constants for server identity, ports, routes, and tool names.

## Development Workflow

- **Build / Dependencies**: `dart pub get` or `make build`
- **Run Server**: `dart run bin/server.dart` or `./run.sh`
- **Run CLI Agent**: `dart run bin/main.dart` or `./cli.sh`
- **Test**: `dart test` or `make test`
- **Static Analysis**: `dart analyze` or `make lint`
- **Container Build**: `docker build -t adk-hello-world-dart .`
