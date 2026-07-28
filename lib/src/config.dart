/// Centralized configuration constants for the MCP and ADK Dart server.
class Config {
  static const String serverName = 'mcp-https-server';
  static const String serverVersion = '1.0.0';
  static const int defaultPort = 8080;

  static const String sseEndpoint = '/sse';
  static const String messagesEndpoint = '/messages';

  static const String toolGreet = 'greet';
  static const String toolGreetParam = 'param';
}
