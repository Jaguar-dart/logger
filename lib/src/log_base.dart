import 'dart:async';
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

abstract class Logger {
  Future<void> log(String level, String message,
      {String id = '', String source, String timestamp});

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

abstract class LogTarget {
  Future<void> append(String line);
}

class FileLogTarget implements LogTarget {
  File file;

  Future _locked;

  FileLogTarget(this.file);

  @override
  Future<void> append(String line) async {
    while (_locked != null) {
      await _locked;
    }
    final completer = Completer();
    _locked = completer.future;

    try {
      await file.writeAsString(line + '\n', mode: FileMode.append, flush: true);
    } catch (e) {
      completer.complete();
      rethrow;
    }
    completer.complete();
  }
}
