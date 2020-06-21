import 'package:jaguar_logger/jaguar_logger.dart';

class StringLogger {
  final List<LogBackend<String>> backends;

  StringLogger(this.backends);

  Future<void> log(String line) async {
    for(final backend in backends) {
      await backend.append(line);
    }
  }
}