# jaguar logger

## Example

```dart
import 'dart:io';

import 'package:jaguar_logger/io.dart';
import 'package:jaguar_logger/jaguar_logger.dart';

Future<void> main() async {
  final logger = Logger([FileBackend(File('/tmp/log.log'))]);
  await logger.info('First message');
  await logger.info('Second message');
}
```

# TODO

+ Rotation
+ Postgres backend
+ Metrics
