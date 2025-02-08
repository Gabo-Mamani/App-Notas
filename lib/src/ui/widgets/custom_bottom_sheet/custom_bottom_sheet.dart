import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget? content;
  final Function()? onTap;

  CustomBottomSheet({Key? key, this.content, this.onTap}) : super(key: key);

  Color background() {
    return ThemeController.instance.brightnessValue
        ? Configure.BACKGROUND_DARK
        : Configure.BACKGROUND_LIGHT;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height - 100,
      width: double.infinity,
      decoration: BoxDecoration(
          color: background(),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: Center(
        child: TextButton(
          child: Text("Cerrar"),
          onPressed: onTap,
        ),
      ),
    );
  }
}
