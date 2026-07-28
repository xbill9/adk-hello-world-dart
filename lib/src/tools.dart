import 'package:adk_dart/adk_dart.dart';
import 'config.dart';
import 'logger.dart';

/// Configures and manages the tools available in the MCP and ADK server.
class Tools {
  /// Formats the greeting message.
  static String formatGreeting(String name) {
    return 'Hello, $name!';
  }

  /// ADK FunctionTool representation for [formatGreeting].
  static final FunctionTool greetFunctionTool = FunctionTool(
    name: Config.toolGreet,
    description: 'Get a greeting from a local HTTPS server.',
    func: ({String? param}) {
      final name = param ?? 'World';
      logger.info('Greeting name via ADK tool: $name');
      return formatGreeting(name);
    },
  );

  /// Definition for the MCP tool schema.
  static Map<String, dynamic> get toolDefinition => {
        'name': Config.toolGreet,
        'description': 'Get a greeting from a local HTTPS server.',
        'inputSchema': {
          'type': 'object',
          'properties': {
            Config.toolGreetParam: {
              'type': 'string',
              'description': 'The name to greet',
            },
          },
          'required': [Config.toolGreetParam],
        },
      };

  /// Handles execution of the greet tool request.
  static String executeGreet(Map<String, dynamic>? arguments) {
    final rawParam = arguments?[Config.toolGreetParam];
    final String name = rawParam?.toString() ?? 'World';
    logger.info('Greeting name: $name');
    return formatGreeting(name);
  }
}
