import 'package:flutter/material.dart';

class LoadingWidgetController {
  LoadingWidgetController._();

  static final instance = LoadingWidgetController._();

  ValueNotifier<bool> loadingNotifier = ValueNotifier<bool>(false);
  ValueNotifier<String> contentNotifier = ValueNotifier<String>("");

  bool loadingValue() => loadingNotifier.value;
  String contentValue() => contentNotifier.value;

  void loading() {
    loadingNotifier.value = true;
  }

  void close() {
    loadingNotifier.value = false;
  }

  void changeText(String value) {
    contentNotifier.value = value;
  }

  void clear() {
    close();
    changeText("");
  }
}
