import 'package:adk_hello_world_dart/adk_hello_world_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Tools tests', () {
    test('formatGreeting formats string correctly', () {
      final greeting = Tools.formatGreeting('Dart');
      expect(greeting, equals('Hello, Dart!'));
    });

    test('executeGreet with null arguments defaults to World', () {
      final greeting = Tools.executeGreet(null);
      expect(greeting, equals('Hello, World!'));
    });

    test('executeGreet with arguments formats correctly', () {
      final greeting = Tools.executeGreet({'param': 'Flutter'});
      expect(greeting, equals('Hello, Flutter!'));
    });

    test('ADK FunctionTool is properly configured', () {
      expect(Tools.greetFunctionTool.name, equals(Config.toolGreet));
      expect(Tools.greetFunctionTool.description, isNotEmpty);
    });
  });
}
