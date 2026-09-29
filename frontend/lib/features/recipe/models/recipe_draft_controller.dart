class RecipeDraftController {
  String Function()? _reader;

  void attach(String Function() reader) {
    _reader = reader;
  }

  void detach(String Function() reader) {
    if (_reader == reader) {
      _reader = null;
    }
  }

  String read() => _reader?.call() ?? '';
}
