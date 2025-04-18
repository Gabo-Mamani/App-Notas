import 'package:app_notas/src/core/services/preferences_service.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();

  static final instance = ThemeController._();

  ValueNotifier<bool> brightness = ValueNotifier<bool>(true);
  bool get brightnessValue => brightness.value;

  Color primary() =>
      brightnessValue ? Configure.PRIMARY : Configure.PRIMARY_DARK;
  Color secondary() => Configure.SECONDARY;
  Color aux() => Configure.AUXILIAR;
  Color accent() => Configure.ACCENT;

  Color primaryButton() => brightnessValue
      ? Configure.PRIMARY_BUTTON_LIGHT
      : Configure.PRIMARY_BUTTON_DARK;
  Color secondaryButton() => Configure.SECONDARY_BUTTON_LIGHT;

  Color background() =>
      brightnessValue ? Configure.BACKGROUND_LIGHT : Configure.BACKGROUND_DARK;

  void changeTheme() async {
    brightness.value = !brightnessValue;
    await PreferencesService.instance.setBool("tema", brightnessValue);
  }

  Future<void> initTheme() async {
    brightness.value = await PreferencesService.instance.getBool("tema");
  }
}
