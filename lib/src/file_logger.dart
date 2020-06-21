import 'dart:async';
import 'dart:io';

import 'package:jaguar_logger/jaguar_logger.dart';

class FileBackend<T> implements LogBackend<T> {
  File file;

  Future _locked;

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
