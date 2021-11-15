

import 'dart:async';

class AppBloc {

  StreamController<String> _title = StreamController<String>.broadcast();  // for more than once listening while widget if on|off

  Stream<String> get titleStream => _title.stream;

  updateTitle(String newTitle) {
    _title.sink.add(newTitle);
  }

  dispose() {
    _title.close();
  }
}
