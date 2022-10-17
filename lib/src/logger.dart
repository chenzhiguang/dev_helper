import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Logger {
  Logger({
    required String file,
    bool empty = true,
  })  : _file = file,
        _empty = empty;

  final String _file;
  final bool _empty;

  File? _fileSystem;
  final _stack = <_Command>[];
  bool _preparing = false;
  String? _leadingLineEnding;

  Future<void> _runStack() async {
    if (_stack.isEmpty || _preparing) {
      return;
    }

    if (_fileSystem == null) {
      _preparing = true;
      final tmpDir = await getTemporaryDirectory();
      final logsDir = Directory('${tmpDir.path}/dev_helper/logs');
      if (!(await logsDir.exists())) {
        await logsDir.create(recursive: true);
      }

      final path = '${logsDir.path}/$_file';
      _fileSystem = File(path);
      _preparing = false;

      if (_empty) {
        _fileSystem!.writeAsStringSync('');
      }
      print('Log file: $path');
    }

    var command = _stack.removeAt(0);

    switch (command.action) {
      case _Action.empty:
        _fileSystem!.writeAsStringSync('');
        _leadingLineEnding = null;
        break;
      case _Action.write:
        var message = command.value!;
        if (_leadingLineEnding == null) {
          _leadingLineEnding = '\n';
        } else {
          message = '$_leadingLineEnding$message';
        }

        _fileSystem!.writeAsStringSync(message, mode: FileMode.append);

        break;
    }

    _runStack();
  }

  void log(Object? message, {bool empty = false}) {
    if (empty) {
      _stack.add(_Command(_Action.empty));
    }
    _stack.add(_Command(_Action.write, message.toString()));
    _runStack();
  }
}

enum _Action { write, empty }

class _Command {
  _Command(this.action, [this.value]);

  final _Action action;
  final String? value;
}
