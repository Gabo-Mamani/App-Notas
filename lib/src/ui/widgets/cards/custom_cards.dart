import 'package:app_notas/src/core/models/note.dart';
import 'package:flutter/material.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';

class SimpleCard extends StatelessWidget {
  final Note note;
  SimpleCard(this.note, {super.key});

  Color background() => ThemeController.instance.brightnessValue
      ? Configure.BACKGROUND_DARK
      : Configure.BACKGROUND_LIGHT;

  Color fontColor() =>
      ThemeController.instance.brightnessValue ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: background()),
      child: Center(
        child: Text(
          note.description ?? "No hay descripcion",
          textAlign: TextAlign.center,
          style: TextStyle(color: fontColor()),
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final Note note;
  ImageCard(this.note, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(note.image ??
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Imagen_no_disponible.svg/480px-Imagen_no_disponible.svg.png")),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              note.description ?? "No hay descripcion",
              style: TextStyle(color: Colors.transparent),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: Colors.black38),
          child: Center(
            child: Text(
              note.description ?? "No hay descripcion",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class TextImageCard extends StatelessWidget {
  final Note note;
  TextImageCard(this.note, {super.key});

  Color background() =>
      !ThemeController.instance.brightnessValue ? Colors.black : Colors.white;

  Color fontColor() =>
      !ThemeController.instance.brightnessValue ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Container(
            height: 75,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(note.image ??
                      "https://upload.wikimedia.org/wikipedia/commons/thumb/d/da/Imagen_no_disponible.svg/480px-Imagen_no_disponible.svg.png")),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            ),
          ),
          Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: background(),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title ?? "No hay titulo",
                    style: TextStyle(color: fontColor()),
                  ),
                  SizedBox(height: 4),
                  Text(
                    note.title ?? "No hay titulo",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
