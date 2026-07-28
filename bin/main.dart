import 'package:adk_hello_world_dart/adk_hello_world_dart.dart';

void main() {
  setupLogger();
  logger.info('Initializing ADK Greeting Agent...');
  final agent = AdkGreetingAgent.createAgent();
  logger.info('Agent created: ${agent.name} (${agent.description})');
  logger.info('Registered tool: ${Tools.greetFunctionTool.name}');
  logger.info('Sample execution: ${Tools.formatGreeting("Dart Developer")}');
}
