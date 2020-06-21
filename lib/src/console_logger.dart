import 'package:jaguar_logger/jaguar_logger.dart';

class ConsoleBackend implements LogBackend<String> {
  @override
  Future<void> append(String record) async {
    print(record);
  }
}