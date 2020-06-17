import 'dart:io';

import 'package:jaguar_logger/jaguar_logger.dart';
import 'package:date_format/date_format.dart' as datefmt;

class FileLogger extends Logger {
  final LogTarget _target;

  FileLogger(this._target);

  factory FileLogger.toFile(File file) => FileLogger(FileLogTarget(file));

  @override
  Future<void> log(String level, String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    timestamp ??= datefmt.formatDate(DateTime.now().toUtc(), [
      datefmt.yyyy,
      '-',
      datefmt.mm,
      '-',
      datefmt.dd,
      'T',
      datefmt.HH,
      ':',
      datefmt.nn,
      ':',
      datefmt.ss,
      '.',
      datefmt.SSS,
    ]);
    await _target.append('$timestamp\t$level\t$id\t$source\t$message');
  }
}