import 'package:flutter/material.dart';

void showSnackBar(GlobalKey<ScaffoldMessengerState> key, String title) {
    key.currentState?.showSnackBar(SnackBar(content: Text(title)));
  }