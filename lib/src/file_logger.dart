import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:date_format/date_format.dart' as datefmt;

import 'package:jaguar_logger/jaguar_logger.dart';

class FileBackend<T> implements LogBackend<T> {
  File file;

  Future? _locked;

  FileBackend(this.file);

  @override
  Future<void> append(T record) async {
    while (_locked != null) {
      await _locked;
    }
    final completer = Completer();
    _locked = completer.future;

    try {
      await file.writeAsString(record.toString() + '\n',
          mode: FileMode.append, flush: true);
    } finally {
      completer.complete();
      _locked = null;
    }
  }
}

class RotatingFileBackend<T> implements LogBackend<T> {
  final Directory dir;

  final String Function(DateTime now) namer;

  Future? _locked;

  RotatingFileBackend(this.dir, {this.namer = periodicNamer});

  File? file;

  @override
  Future<void> append(T record) async {
    while (_locked != null) {
      await _locked;
    }
    final completer = Completer();
    _locked = completer.future;

    final name = namer(DateTime.now());
    final path = join(dir.path, name);
    if (file == null || file!.path != path) {
      file = File(path);
    }

    try {
      await file!.writeAsString(record.toString() + '\n',
          mode: FileMode.append, flush: true);
    } finally {
      completer.complete();
      _locked = null;
    }
  }

  static String periodicNamer(DateTime now,
      {Duration period = const Duration(days: 1)}) {
    final truncated = now.toUtc().truncate(period);
    return datefmt
        .formatDate(truncated, [datefmt.yy, '-', datefmt.mm, '-', datefmt.dd]);
  }
}

extension DateTimeExt on DateTime {
  DateTime truncate(Duration duration) {
    final epoch = microsecondsSinceEpoch % duration.inMicroseconds;
    return DateTime.fromMicrosecondsSinceEpoch(epoch, isUtc: isUtc);
  }
}
