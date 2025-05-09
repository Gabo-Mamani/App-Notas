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

class NoteVisual extends StatelessWidget {
  final Note note;

  const NoteVisual({super.key, required this.note});

  String _parseDate(String? date) {
    try {
      final _date = date?.split("-");
      if (_date == null || _date.length != 3) return "";
      final day = _date[0];
      final month = int.parse(_date[1]);
      final year = _date[2];
      return "$day de ${Constants.nameMonth[month]} del $year";
    } catch (_) {
      return date ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    return Container(
      decoration: BoxDecoration(
        color: theme.background(),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (note.image != null && note.image!.trim().isNotEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: note.image!.startsWith("http")
                    ? Image.network(
                        note.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.grey),
                          );
                        },
                      )
                    : Image.file(
                        File(note.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.broken_image,
                                size: 48, color: Colors.grey),
                          );
                        },
                      ),
              ),
            ),
          const SizedBox(height: 16),
          if ((note.title?.isNotEmpty ?? false))
            Text(
              note.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textColor(),
              ),
            ),
          const SizedBox(height: 8),
          if ((note.description?.isNotEmpty ?? false))
            Text(
              note.description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor(),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _parseDate(note.date),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.deepOrange.shade300,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final Note? currentNote =
        (routeArgs is NotePageArguments ? routeArgs.note : null) ?? note;

    if (currentNote == null) {
      return Scaffold(
        body: Center(
          child:
              Text("Nota no disponible", style: TextStyle(color: fontColor())),
        ),
      );
    }

    final theme = ThemeController.instance;

    return Scaffold(
      backgroundColor: theme.background(),
      appBar: AppBar(
        automaticallyImplyLeading: !repaint,
        leading: repaint
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios, color: fontColor()),
                onPressed: () => Navigator.pop(context),
              ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          _title(currentNote),
          style: TextStyle(color: fontColor()),
        ),
        actions: repaint
            ? null
            : [
                IconButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("¿Eliminar nota?"),
                        content: Text("¿Deseas mover esta nota a la papelera?"),
                        actions: [
                          TextButton(
                              child: Text("Cancelar"),
                              onPressed: () => Navigator.pop(context, false)),
                          TextButton(
                              child: Text("Mover a papelera"),
                              onPressed: () => Navigator.pop(context, true)),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final response =
                          await _services.update("notes", currentNote.id!, {
                        "deleted": true,
                      });

                      if (response["status"] == StatusNetwork.Connected) {
                        Navigator.pop(context, true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Nota movida a la papelera")),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("Error al mover la nota a la papelera")),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.delete, color: fontColor()),
                ),
              ],
      ),
      floatingActionButton: repaint
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AddNotePage.ADD_NOTE_PAGE_ROUTE,
                  arguments:
                      AddNotePageArguments(note: currentNote, edit: true),
                );

                if (result == "edit") {
                  Navigator.pop(context, true);
                }
              },
              child: Icon(Icons.edit),
            ),
      body: NoteBody(currentNote),
    );
  }
}

class NoteBody extends StatefulWidget {
  final Note note;
  NoteBody(this.note, {Key? key}) : super(key: key);

  @override
  _NoteBodyState createState() => _NoteBodyState();
}

class _NoteBodyState extends State<NoteBody> {
  final _repaintKey = GlobalKey();
  Uint8List? listBytes;

  Widget _image() {
    if (widget.note.type == TypeNote.Image ||
        widget.note.type == TypeNote.ImagenNetwork ||
        widget.note.type == TypeNote.TextImage ||
        widget.note.type == TypeNote.TextImageNetwork) {
      final imageProvider =
          widget.note.image != null && widget.note.image!.startsWith("http")
              ? NetworkImage(widget.note.image!)
              : FileImage(File(widget.note.image!)) as ImageProvider;

      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: imageProvider,
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
            child: NoteVisual(note: widget.note),
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
