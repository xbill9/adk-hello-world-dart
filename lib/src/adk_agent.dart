import 'package:adk_dart/adk_dart.dart';
import 'tools.dart';

/// Configures and creates the sample ADK Agent using adk_dart.
class AdkGreetingAgent {
  /// Returns an [LlmAgent] configured with the greet tool.
  static LlmAgent createAgent() {
    return LlmAgent(
      name: 'GreetingAgent',
      description: 'An AI Agent built with adk_dart that provides greetings.',
      instruction: 'You are a friendly greeting assistant. Use the greet tool to provide personalized greetings.',
      tools: [Tools.greetFunctionTool],
    );
  }
}
