import 'dart:typed_data';
import 'dart:ui';

import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/file_services.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/pages/add_note_page.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class NotePageArguments {
  final Note? note;
  NotePageArguments({this.note});
}

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class NotePage extends StatelessWidget {
  final Note? note;
  final bool repaint;
  NotePage({Key? key, this.note, this.repaint = false}) : super(key: key);

  static const NOTE_PAGE_ROUTE = "note_page";

  final FirebaseServices _services = FirebaseServices.instance;

  String _title(Note note) {
    if (note.title != null) {
      return note.title!;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    NotePageArguments arguments =
        ModalRoute.of(context)?.settings.arguments as NotePageArguments;
    final theme = ThemeController.instance;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeController.instance.primary(),
        onPressed: () => Navigator.pushNamed(
            context, AddNotePage.ADD_NOTE_PAGE_ROUTE,
            arguments: AddNotePageArguments(note: arguments.note, edit: true)),
        child: Icon(Icons.edit),
      ),
      backgroundColor: theme.background(),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            _title(arguments.note!),
            style: TextStyle(color: fontColor()),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  final response =
                      await _services.delete("notes", arguments.note!.id!);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.delete, color: fontColor()))
          ]),
      body: _Body(arguments.note!),
    );
  }
}

class _Body extends StatefulWidget {
  final Note note;
  _Body(this.note, {Key? key}) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

// ... (todo el import y el resto del archivo sin cambios hasta __BodyState)

class __BodyState extends State<_Body> {
  final _repaintKey = GlobalKey();
  Uint8List? listBytes;

  Widget _image() {
    if (widget.note.type == TypeNote.Image ||
        widget.note.type == TypeNote.ImagenNetwork ||
        widget.note.type == TypeNote.TextImage ||
        widget.note.type == TypeNote.TextImageNetwork) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.note.image ?? Constants.defaultImage),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return Container();
  }

  void urls(String text) {
    widget.note.urls = [];
    RegExp regexp =
        RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> match = regexp.allMatches(text);
    match.forEach((element) {
      widget.note.urls?.add(text.substring(element.start, element.end));
    });
  }

  String parseDate() {
    try {
      print("Fecha original: ${widget.note.date}"); // 🪵 log de depuración
      final _date = widget.note.date?.split("-");
      if (_date == null || _date.length != 3) return "";

      final day = _date[0];
      final month = int.parse(_date[1]);
      final year = _date[2];

      if (month >= 1 && month <= 12) {
        return "$day de ${Constants.nameMonth[month]} del $year";
      } else {
        return widget.note.date ?? "";
      }
    } catch (e) {
      print("Error parseando la fecha: $e");
      return widget.note.date ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    urls(widget.note.description ?? "");
    return Column(
      children: [
        RepaintBoundary(
          key: _repaintKey,
          child: Column(
            children: [
              _image(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.note.description ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: fontColor()),
                    ),
                    Text(
                      parseDate(),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: ThemeController.instance.primary()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: widget.note.urls?.length ?? 0,
            itemBuilder: (context, index) {
              final url = widget.note.urls![index];
              return ListTile(
                onTap: () {
                  launch(url);
                },
                title: Text(
                  url,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.blue),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: MediumButton(
            title: "Descargar",
            onTap: () async {
              final RenderRepaintBoundary render = _repaintKey.currentContext!
                  .findRenderObject() as RenderRepaintBoundary;
              final image = await render.toImage();
              final bytes = await image.toByteData(format: ImageByteFormat.png);

              listBytes = bytes!.buffer.asUint8List();
              if (listBytes != null) {
                await FileServices.instance
                    .saveBytes("Captura.png", listBytes!);
              }
            },
          ),
        ),
      ],
    );
  }
}
