import 'package:logging/logging.dart';

final Logger logger = Logger('MCPServer');

void setupLogger() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('[${record.level.name}] ${record.time}: ${record.message}');
  });
}
