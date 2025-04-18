import 'package:flutter/material.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final bool private;
  final Function(String)? textEntry;
  final Function()? action;
  final IconData? icon;

  const TextInput({
    Key? key,
    this.controller,
    this.title = "",
    this.textEntry,
    this.action,
    this.icon = Icons.check,
    this.private = false,
  }) : super(key: key);

  Color get fillColor => ThemeController.instance.brightnessValue
      ? Colors.grey[300]!
      : Colors.grey[800]!;

  Color get textColor =>
      ThemeController.instance.brightnessValue ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          TextField(
            obscureText: private,
            controller: controller,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              suffixIcon: action != null
                  ? IconButton(
                      onPressed: action,
                      icon: Icon(icon, color: textColor),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LargeTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String title;
  final Function(String)? textEntry;

  const LargeTextInput({
    Key? key,
    this.controller,
    this.title = "",
    this.textEntry,
  }) : super(key: key);

  Color get fillColor => ThemeController.instance.brightnessValue
      ? Colors.grey[300]!
      : Colors.grey[800]!;

  Color get textColor =>
      ThemeController.instance.brightnessValue ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLines: 6,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
