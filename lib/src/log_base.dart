import 'dart:async';

import 'package:stack_trace/stack_trace.dart';
import 'package:date_format/date_format.dart' as datefmt;

String stringifyTimestamp(DateTime time) {
  return datefmt.formatDate(time.toUtc(), [
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
}

class Logger {
  final List<LogBackend<LogRecord>> backends;

  Logger(this.backends);

  Future<void> log(String level, String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    timestamp ??= stringifyTimestamp(DateTime.now().toUtc());

    for (final backend in backends) {
      await backend.append(LogRecord(
          timestamp: timestamp,
          level: level,
          id: id,
          source: source,
          message: message));
    }
  }

  // ignore: missing_return
  Future<void> debug(String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('DEBUG', message, id: id, source: source, timestamp: timestamp);
  }

  Future<void> info(String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('INFO', message, id: id, source: source, timestamp: timestamp);
  }

  Future<void> warning(String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('WARNING', message, id: id, source: source, timestamp: timestamp);
  }

  Future<void> error(String message,
      {String id = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('ERROR', message, id: id, source: source, timestamp: timestamp);
  }
}

String getLineInfo() {
  final trace = Trace.current(2);

  final frame = trace.frames.first;
  final file = frame.uri.pathSegments.last;
  return '$file:${frame.line}';
}

class LogRecord {
  final String timestamp;

  final String level;

  final String id;

  final String source;

  final String message;

  LogRecord({this.timestamp, this.level, this.id, this.source, this.message});

  @override
  String toString() => '$timestamp\t$level\t$id\t$source\t$message';

  Map<String, dynamic> asMap() => {
        'timestamp': timestamp,
        'level': level,
        'id': id,
        'source': source,
        'message': message,
      };
}

abstract class LogBackend<T> {
  Future<void> append(T record);
}
