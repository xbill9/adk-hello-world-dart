import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import 'config.dart';
import 'logger.dart';
import 'tools.dart';

/// Service managing MCP sessions over Server-Sent Events (SSE).
class SessionService {
  final Map<String, StreamController<String>> _transports = {};
  final Uuid _uuid = const Uuid();

  /// Handles incoming SSE connections on [Config.sseEndpoint].
  Response handleSseSession(Request request) {
    final sessionId = _uuid.v4();
    final controller = StreamController<String>();
    _transports[sessionId] = controller;

    logger.info('New SSE session created: $sessionId');

    controller.onListen = () {
      logger.info('SSE client connected and listening: $sessionId');
      _sendSseEvent(
        sessionId,
        'endpoint',
        '${Config.messagesEndpoint}?sessionId=$sessionId',
      );
    };

    controller.onCancel = () {
      logger.info('SSE session closed: $sessionId');
      _transports.remove(sessionId);
      controller.close();
    };

    return Response.ok(
      controller.stream.transform(utf8.encoder),
      headers: {
        'Content-Type': 'text/event-stream; charset=utf-8',
        'Cache-Control': 'no-cache, no-transform',
        'Connection': 'keep-alive',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      },
    );
  }

  /// Handles POST messages sent to [Config.messagesEndpoint].
  Future<Response> handlePostMessage(Request request) async {
    final sessionId = request.url.queryParameters['sessionId'];
    logger.info('POST /messages received with sessionId: $sessionId');

    if (sessionId == null || sessionId.isEmpty) {
      return Response.badRequest(
        body: 'Missing sessionId',
        headers: {'Access-Control-Allow-Origin': '*'},
      );
    }

    final controller = _transports[sessionId];
    if (controller == null) {
      logger.warning('No active transport found for sessionId: $sessionId');
      return Response.badRequest(
        body: 'Invalid sessionId',
        headers: {'Access-Control-Allow-Origin': '*'},
      );
    }

    try {
      final body = await request.readAsString();
      if (body.trim().isEmpty) {
        return Response.ok('Accepted', headers: {'Access-Control-Allow-Origin': '*'});
      }

      final Map<String, dynamic> jsonMsg = jsonDecode(body);
      final dynamic id = jsonMsg['id'];
      final String? method = jsonMsg['method'];

      logger.info('Received RPC method "$method" for session $sessionId');

      if (method == 'initialize') {
        final response = {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'protocolVersion': '2024-11-05',
            'capabilities': {
              'tools': {'listChanged': true},
            },
            'serverInfo': {
              'name': Config.serverName,
              'version': Config.serverVersion,
            },
          },
        };
        _sendSseEvent(sessionId, 'message', jsonEncode(response));
      } else if (method == 'notifications/initialized') {
        // Notification, no response needed
      } else if (method == 'ping') {
        final response = {
          'jsonrpc': '2.0',
          'id': id,
          'result': {},
        };
        _sendSseEvent(sessionId, 'message', jsonEncode(response));
      } else if (method == 'tools/list') {
        final response = {
          'jsonrpc': '2.0',
          'id': id,
          'result': {
            'tools': [Tools.toolDefinition],
          },
        };
        _sendSseEvent(sessionId, 'message', jsonEncode(response));
      } else if (method == 'tools/call') {
        final params = jsonMsg['params'] as Map<String, dynamic>?;
        final name = params?['name'] as String?;
        final arguments = params?['arguments'] as Map<String, dynamic>?;

        if (name == Config.toolGreet) {
          final greeting = Tools.executeGreet(arguments);
          final response = {
            'jsonrpc': '2.0',
            'id': id,
            'result': {
              'content': [
                {
                  'type': 'text',
                  'text': greeting,
                },
              ],
            },
          };
          _sendSseEvent(sessionId, 'message', jsonEncode(response));
        } else {
          final errorResponse = {
            'jsonrpc': '2.0',
            'id': id,
            'error': {
              'code': -32601,
              'message': 'Tool not found: $name',
            },
          };
          _sendSseEvent(sessionId, 'message', jsonEncode(errorResponse));
        }
      } else {
        if (id != null) {
          final errorResponse = {
            'jsonrpc': '2.0',
            'id': id,
            'error': {
              'code': -32601,
              'message': 'Method not found: $method',
            },
          };
          _sendSseEvent(sessionId, 'message', jsonEncode(errorResponse));
        }
      }

      return Response.ok(
        'Accepted',
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'text/plain',
        },
      );
    } catch (e, stack) {
      logger.severe('Error handling POST message for session $sessionId', e, stack);
      return Response.internalServerError(
        body: 'Error handling message: $e',
        headers: {'Access-Control-Allow-Origin': '*'},
      );
    }
  }

  void _sendSseEvent(String sessionId, String event, String data) {
    final controller = _transports[sessionId];
    if (controller != null && !controller.isClosed) {
      final padding = ' ' * 8192;
      controller.add('event: $event\ndata: $data\n\n: $padding\n\n');
    }
  }

  /// Active session count.
  int get activeSessionCount => _transports.length;
}
