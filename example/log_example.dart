import 'dart:io';

import 'package:jaguar_logger/io.dart';

Future<void> main() async {
  final logger = FileLogger.toFile(File('/tmp/log.log'));
  await logger.info('First message');
}
