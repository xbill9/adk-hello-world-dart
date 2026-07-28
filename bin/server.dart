import 'dart:io';
import 'package:adk_hello_world_dart/adk_hello_world_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        });
      }
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      });
    };
  };
}

void main() async {
  setupLogger();

  final sessionService = SessionService();
  final router = Router();

  router.get('/health', (Request request) => Response.ok('OK'));
  router.get('/', (Request request) => Response.ok('ADK & MCP Dart Server Running'));

  router.get(Config.sseEndpoint, sessionService.handleSseSession);
  router.post(Config.messagesEndpoint, sessionService.handlePostMessage);

  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addHandler(router.call);

  final portStr = Platform.environment['PORT'];
  final port = int.tryParse(portStr ?? '') ?? Config.defaultPort;

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  logger.info('ADK & MCP Dart Server running on http://${server.address.host}:${server.port}');
}
