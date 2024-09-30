import 'package:flutter/widgets.dart';

extension ContextHelper on BuildContext {
  void pop<T extends Object>([T? result]) {
    if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop(result);
    }
  }

  void push(String path, {Object? extra}) {
    Navigator.of(this).pushNamed(path, arguments: extra);
  }
}
