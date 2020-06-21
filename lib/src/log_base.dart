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

  dynamic /* String | Set<String> */ _filter;

  Logger(this.backends);

  Future<void> log(String level, String message,
      {String groupId = '', String source, String timestamp}) async {
    if (_filter != null) {
      if (_filter is String) {
        if ((knownLevels[level] ?? double.infinity) > knownLevels[_filter]) {
          return;
        }
      } else {
        if (!(_filter as Set<String>).contains(level)) {
          return;
        }
      }
    }

    source ??= getLineInfo();
    timestamp ??= stringifyTimestamp(DateTime.now().toUtc());

    for (final backend in backends) {
      await backend.append(LogRecord(
          timestamp: timestamp,
          level: level,
          groupId: groupId,
          source: source,
          message: message));
    }
  }

  // ignore: missing_return
  Future<void> debug(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('DEBUG', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  Future<void> info(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('INFO', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  Future<void> warning(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('WARNING', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  Future<void> error(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('ERROR', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  set filter(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'ERROR':
        case 'WARNING':
        case 'DEBUG':
        case 'INFO':
          _filter = value;
          break;
        default:
          throw Exception('Invalid level');
      }
    } else if (value is Set<String>) {
      _filter = value.toSet();
    }
  }

  static const knownLevels = {
    'ERROR': 0,
    'WARNING': 1,
    'INFO': 2,
    'DEBUG': 3,
  };
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

  final String groupId;

  final String source;

  final String message;

  LogRecord(
      {this.timestamp, this.level, this.groupId, this.source, this.message});

  @override
  String toString() => '$timestamp\t$level\t$groupId\t$source\t$message';

  Map<String, dynamic> asMap() => {
        'timestamp': timestamp,
        'level': level,
        'groupId': groupId,
        'source': source,
        'message': message,
      };
}

abstract class LogBackend<T> {
  Future<void> append(T record);
}
