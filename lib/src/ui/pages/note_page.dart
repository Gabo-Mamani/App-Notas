import 'dart:io';
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
    return note.title ?? "";
  }

  @override
  Widget build(BuildContext context) {
    NotePageArguments arguments =
        ModalRoute.of(context)?.settings.arguments as NotePageArguments;
    final theme = ThemeController.instance;

    return Scaffold(
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

              if (response["status"] == StatusNetwork.Connected) {
                Navigator.pop(context, true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Nota eliminada exitosamente")),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error al eliminar la nota")),
                );
              }
            },
            icon: Icon(Icons.delete, color: fontColor()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AddNotePage.ADD_NOTE_PAGE_ROUTE,
            arguments: AddNotePageArguments(note: arguments.note, edit: true),
          );

          if (result == "edit") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("¡Nota actualizada exitosamente!")),
              );
            });
          }
        },
        child: Icon(Icons.edit),
      ),
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
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(File(widget.note.image!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Descargar como imagen (PNG)'),
              onTap: () async {
                Navigator.pop(context);
                await _downloadAsImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('Descargar como PDF'),
              onTap: () async {
                Navigator.pop(context);
                await _downloadAsPDF();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadAsImage() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      listBytes = byteData?.buffer.asUint8List();

      if (listBytes != null) {
        final title = widget.note.title?.replaceAll(" ", "_") ?? "nota";
        await FileServices.instance.saveBytes(
          "$title.png",
          listBytes!,
          folder: "Imágenes",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Imagen guardada en carpeta Imágenes")),
        );
      }
    } catch (e) {
      print("Error al capturar imagen: $e");
    }
  }

  Future<void> _downloadAsPDF() async {
    final title = widget.note.title?.replaceAll(" ", "_") ?? "nota";
    await FileServices.instance.generatePDF(
      widget.note,
      fileName: "$title.pdf",
      folder: "Documentos",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF guardado en carpeta Documentos")),
    );
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
      return widget.note.date ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    urls(widget.note.description ?? "");

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            key: _repaintKey,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeController.instance.background(),
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image(),
                  const SizedBox(height: 16),
                  Text(
                    widget.note.description ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeController.instance.textColor(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    parseDate(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepOrange.shade300,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ((widget.note.urls?.length ?? 0) > 0)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.note.urls?.length ?? 0,
              itemBuilder: (context, index) {
                final url = widget.note.urls![index];
                return ListTile(
                  onTap: () => launch(url),
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              child: MediumButton(
                title: "Descargar",
                onTap: () => _showDownloadOptions(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
