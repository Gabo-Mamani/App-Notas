import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class MediumButton extends StatelessWidget {
  final String title;
  final bool primaryColor;
  final IconData? icon;
  final Function? onTap;
  const MediumButton({
    Key? key,
    this.title = "",
    this.primaryColor = true,
    this.icon,
    this.onTap,
  }) : super(key: key);

  Color getColor() {
    return this.primaryColor?ThemeController.instance.primaryButton():ThemeController.instance.secondaryButton();
  }

  Color getColorText() {
    return !ThemeController.instance.brightnessValue ? Colors.black:Colors.white;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: getColor(),
        borderRadius: BorderRadius.circular(32)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon != null ? Icon(icon) : SizedBox(),
          SizedBox(width: icon != null ? 8 : 0),
          Text(
            title,
            style: TextStyle(color: getColorText(), fontSize: 16),
            )
        ],),
    );
  }
}