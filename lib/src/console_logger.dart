import 'package:jaguar_logger/jaguar_logger.dart';

class ConsoleBackend<T> implements LogBackend<T> {
  @override
  Future<void> append(dynamic record) async {
    print(record.toString());
  }
}
