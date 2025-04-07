import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class SimpleTile extends StatelessWidget {
  final String title;
  final IconData? leading;
  final IconData? trailing;
  final Function()? onTap;

  Color getColorText() {
    return ThemeController.instance.brightnessValue
        ? Colors.black
        : Colors.white;
  }

  SimpleTile(
      {Key? key, this.title = "", this.leading, this.trailing, this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(color: getColorText())),
      leading: leading != null
          ? Icon(leading, color: getColorText())
          : SizedBox(
              height: 0,
            ),
      trailing:
          trailing != null ? Icon(trailing, color: Colors.grey) : SizedBox(),
    );
  }
}

class ImageTile extends StatelessWidget {
  final String title;
  final String image;
  final String description;
  final Function()? onTap;
  final String? date;

  Color getColorText() {
    return ThemeController.instance.brightnessValue
        ? Colors.black
        : Colors.white;
  }

  ImageTile(
      {Key? key,
      this.title = "",
      this.date,
      this.image =
          "https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Imagen_no_disponible.svg/480px-Imagen_no_disponible.svg.png",
      this.description = "",
      this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(color: getColorText())),
      leading: Container(
        height: 85,
        width: 50,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(8)),
      ),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          description,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.blueGrey),
        ),
        Text(date ?? "",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ThemeController.instance.primary(),
                fontWeight: FontWeight.bold))
      ]),
    );
  }
}
