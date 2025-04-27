import 'dart:io';

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

Widget _fallbackIcon() {
  return Container(
    width: 50,
    height: 85,
    color: Colors.grey.shade300,
    child: Icon(Icons.broken_image, color: Colors.grey),
  );
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

  const ImageTile({
    Key? key,
    this.title = "",
    this.date,
    this.image = "",
    this.description = "",
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool showDefaultImage =
        image.trim().isEmpty || !File(image).existsSync();

    return ListTile(
      onTap: onTap,
      title: Text(title, style: TextStyle(color: getColorText())),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (image.startsWith('http') || image.startsWith('https'))
            ? Image.network(
                image,
                width: 50,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              )
            : File(image).existsSync()
                ? Image.file(
                    File(image),
                    width: 50,
                    height: 85,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          Text(
            date ?? "",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ThemeController.instance.primary(),
                  fontWeight: FontWeight.bold,
                ),
          )
        ],
      ),
    );
  }
}
