---
title: ADK Development with Dart/Flutter, Cloud Run, and Gemini CLI
published: false
description: Learn how to build AI Agents using Google's Agent Development Kit (adk_dart), Dart/Flutter, Cloud Run, and Gemini CLI.
tags: dart, flutter, ai, googlecloudrun
cover_image: https://media2.dev.to/dynamic/image/width=1000,height=500,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fp97z61j4asvqerm16teq.png
---

# ADK Development with Dart/Flutter, Cloud Run, and Gemini CLI

Building intelligent AI agents directly within the Dart and Flutter ecosystem is now a reality. With Google's **Agent Development Kit for Dart (`adk_dart`)** and **Model Context Protocol (`adk_mcp`)**, Dart and Flutter developers can build, run, and deploy full-fledged AI agents without writing Python or Node.js bridge code.

In this guide, we'll walk through building a complete **ADK & MCP Agent Server** in Dart, testing it locally using **Gemini CLI**, and deploying it to **Google Cloud Run**.

---

## Why ADK for Dart & Flutter?

The **Agent Development Kit (ADK)** allows developers to define AI agents (`LlmAgent`), encapsulate domain capabilities into strongly-typed tools (`FunctionTool`), manage multi-turn session persistence, and stream responses in real-time.

Key advantages of using ADK in Dart:
* **Single Language Stack**: Write your app UI, agent logic, and backend services entirely in Dart.
* **Type Safety & Fast AOT Performance**: Benefit from Dart's strict static typing and quick startup times.
* **Cloud & Serverless Ready**: Package your ADK server into a lightweight Docker container for Google Cloud Run.
* **Gemini & Multi-LLM Support**: Seamlessly integrate Google Gemini models alongside custom tools.

---

## System Architecture

```mermaid
graph TD
    Client[Gemini CLI / Web / IDE] -->|SSE & HTTP POST| Server[Dart ADK Server (Shelf)]
    Server -->|Session & Routing| Sessions[SessionService]
    Server -->|Agent Execution| ADK[ADK LlmAgent]
    ADK -->|Tool Calls| Tools[FunctionTool / Domain Logic]
    Server -->|Deployment| CloudRun[Google Cloud Run]
```

---

## Step 1: Setting Up the Project

Create a new Dart project and configure your `pubspec.yaml` with `adk_dart`, `adk_mcp`, and `shelf`:

```yaml
name: adk_hello_world_dart
description: A Dart-based Agent Development Kit (ADK) sample server.
version: 1.0.0

environment:
  sdk: '^3.5.0'

dependencies:
  adk_dart: ^2026.7.24
  adk_mcp: ^2026.7.24
  shelf: ^1.4.1
  shelf_router: ^1.1.4
  uuid: ^4.5.1
  logging: ^1.3.0

dev_dependencies:
  http: ^1.2.2
  lints: ^4.0.0
  test: ^1.25.0
```

Install dependencies:

```bash
dart pub get
```

---

## Step 2: Defining ADK Tools (`FunctionTool`)

In ADK, tools encapsulate executable functions that agents can invoke. Here we create a `formatGreeting` function and wrap it in an ADK `FunctionTool`:

```dart
import 'package:adk_dart/adk_dart.dart';

class Tools {
  /// Pure domain logic function.
  static String formatGreeting(String name) {
    return 'Hello, $name!';
  }

  /// ADK FunctionTool wrapper.
  static final FunctionTool greetFunctionTool = FunctionTool(
    name: 'greet',
    description: 'Get a greeting from a local HTTPS server.',
    func: ({String? param}) {
      final name = param ?? 'World';
      return formatGreeting(name);
    },
  );
}
```

---

## Step 3: Creating the ADK Agent (`LlmAgent`)

Using `adk_dart`, define your AI Agent with instructions and attached tools:

```dart
import 'package:adk_dart/adk_dart.dart';
import 'tools.dart';

class AdkGreetingAgent {
  static LlmAgent createAgent() {
    return LlmAgent(
      name: 'GreetingAgent',
      description: 'An AI Agent built with adk_dart that provides greetings.',
      instruction: 'You are a friendly greeting assistant. Use the greet tool to provide personalized greetings.',
      tools: [Tools.greetFunctionTool],
    );
  }
}
```

---

## Step 4: Building the Server & SSE Session Transport

Create the web server using `shelf` and `shelf_router` to handle Server-Sent Events (SSE) streaming and HTTP POST message processing:

```dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:adk_hello_world_dart/adk_hello_world_dart.dart';

void main() async {
  setupLogger();

  final sessionService = SessionService();
  final router = Router();

  router.get('/health', (Request request) => Response.ok('OK'));
  router.get(Config.sseEndpoint, sessionService.handleSseSession);
  router.post(Config.messagesEndpoint, sessionService.handlePostMessage);

  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final portStr = Platform.environment['PORT'];
  final port = int.tryParse(portStr ?? '') ?? Config.defaultPort;

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  logger.info('ADK Dart Server running on http://${server.address.host}:${server.port}');
}
```

---

## Step 5: Testing Locally with Gemini CLI

Run the server locally:

```bash
dart run bin/server.dart
```

In your Gemini CLI or MCP client configuration (`.idx/mcp.json` or client settings), point the client to your server's SSE endpoint:

```json
{
  "mcpServers": {
    "dart-adk-server": {
      "url": "http://localhost:8080/sse"
    }
  }
}
```

Now you can prompt Gemini CLI to greet users using your Dart ADK tools!

---

## Step 6: Deploying to Google Cloud Run

To deploy your ADK server to Google Cloud Run, package it using Docker:

### `Dockerfile`

```dockerfile
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o bin/server

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server

ENV PORT=8080
EXPOSE 8080

CMD ["/app/bin/server"]
```

### Deploying via Cloud Build & Cloud Run

Deploy directly using `gcloud`:

```bash
gcloud run deploy adk-hello-world-dart \
  --source . \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --max-instances 1
```

---

## Conclusion

With `adk_dart` and `adk_mcp`, Dart and Flutter developers have a native framework to build, test, and deploy intelligent AI agents. Whether building CLI helpers, full-stack Flutter backends, or cloud-hosted AI microservices, the Dart ADK ecosystem provides a seamless developer experience.

### Next Steps
* Check out the [ADK Dart Package on pub.dev](https://pub.dev/packages/adk_dart)
* Explore multi-agent collaboration with `SequentialAgent` and `ParallelAgent`
* Integrate Vertex AI and Gemini models into your Flutter applications!
