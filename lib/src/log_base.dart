import 'dart:async';

import 'package:stack_trace/stack_trace.dart';
import 'package:date_format/date_format.dart' as datefmt;

abstract class Logger {
  factory Logger(List<LogBackend<LogRecord>> backends, {dynamic filter}) =
      _LoggerImpl;

  List<LogBackend<LogRecord>> get backends;

  Future<void> log(String level, String message,
      {String groupId = '', String source, String timestamp});

  Future<void> debug(String message,
      {String groupId = '', String source, String timestamp});

  Future<void> info(String message,
      {String groupId = '', String source, String timestamp});

  Future<void> warning(String message,
      {String groupId = '', String source, String timestamp});

  Future<void> error(String message,
      {String groupId = '', String source, String timestamp});

  set filter(dynamic value);

  Logger loggerWith({String groupId = ''});
}

class _LoggerImpl implements Logger {
  @override
  final List<LogBackend<LogRecord>> backends;

  dynamic /* String | Set<String> */ _filter;

  _LoggerImpl(this.backends, {dynamic filter}) {
    if (filter != null) {
      this.filter = filter;
    }
  }

  @override
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

  @override
  Future<void> debug(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('DEBUG', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
  Future<void> info(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('INFO', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
  Future<void> warning(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('WARNING', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
  Future<void> error(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('ERROR', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
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

  @override
  Logger loggerWith({String groupId = ''}) =>
      LoggerWith(this, withGroupId: groupId);

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

class LoggerWith implements Logger {
  final Logger _inner;

  final String withGroupId;

  LoggerWith(this._inner, {this.withGroupId = ''});

  @override
  List<LogBackend<LogRecord>> get backends => _inner.backends;

  @override
  Future<void> log(String level, String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await _inner.log(level, message,
        groupId: groupId.isNotEmpty ? groupId : withGroupId,
        source: source,
        timestamp: timestamp);
  }

  // ignore: missing_return
  @override
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

  @override
  Future<void> warning(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('WARNING', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
  Future<void> error(String message,
      {String groupId = '', String source, String timestamp}) async {
    source ??= getLineInfo();
    await log('ERROR', message,
        groupId: groupId, source: source, timestamp: timestamp);
  }

  @override
  set filter(dynamic value) => _inner.filter = value;

  @override
  Logger loggerWith({String groupId = ''}) =>
      LoggerWith(this, withGroupId: groupId.isNotEmpty ? groupId : withGroupId);
}

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
