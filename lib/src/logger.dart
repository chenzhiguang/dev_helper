import 'dart:io';

/// Creates a logger which outputs the string result to a log [file].
class Logger {
  Logger({
    required this.file,
    this.dir = '/tmp/logs/',
    bool empty = true,
  }) {
    if (empty) {
      emptyFile(path);
    }
  }

  final String dir;
  final String file;

  String get path => '$dir/$file';

  /// Logs the given [message] to [file].
  void log(Object? message) => logToFile(message, path, append: true);

  /// Logs the given [message] to [file].
  static void logToFile(Object? message, String file, {bool append = false}) {
    final fileObject = File(file);
    var content = message is String ? message : message.toString();

    if (append) {
      final oldContent = fileObject.readAsStringSync();

      if (oldContent.isNotEmpty) {
        content = '$oldContent\n$message';
      }
    }

    fileObject.writeAsStringSync(content);
  }

  /// Empties a file.
  static void emptyFile(String file) {
    File(file).writeAsStringSync('');
  }
}
