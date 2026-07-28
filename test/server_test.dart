import 'dart:io';
import 'package:adk_hello_world_dart/adk_hello_world_dart.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

void main() {
  group('Server Endpoints', () {
    late HttpServer server;
    late String baseUrl;

    setUp(() async {
      final sessionService = SessionService();
      final router = Router();
      router.get('/health', (Request request) => Response.ok('OK'));
      router.get(Config.sseEndpoint, sessionService.handleSseSession);
      router.post(Config.messagesEndpoint, sessionService.handlePostMessage);

      server = await io.serve(router.call, InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://${server.address.host}:${server.port}';
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('Health endpoint returns OK', () async {
      final res = await http.get(Uri.parse('$baseUrl/health'));
      expect(res.statusCode, equals(200));
      expect(res.body, equals('OK'));
    });

    test('POST without sessionId returns 400', () async {
      final res = await http.post(Uri.parse('$baseUrl/messages'));
      expect(res.statusCode, equals(400));
    });
  });
}
