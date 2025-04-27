import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/core/services/file_services.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/widgets/common/safe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

Color fontColor() =>
    ThemeController.instance.brightnessValue ? Colors.black : Colors.white;

class SelectNotesImagePage extends StatefulWidget {
  static const SELECT_NOTES_IMAGE_ROUTE = "select_notes_image_page";

  const SelectNotesImagePage({super.key});

  @override
  State<SelectNotesImagePage> createState() => _SelectNotesImagePageState();
}

class _SelectNotesImagePageState extends State<SelectNotesImagePage> {
  final _services = FirebaseServices.instance;
  final Map<Note, bool> selectedNotes = {};
  final Map<Note, GlobalKey> repaintKeys = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final response = await _services.read("notes");
    if (response["status"] == StatusNetwork.Connected) {
      final notes = (response["data"] as List)
          .cast<Note>()
          .where((n) => !n.private)
          .toList();
      notes.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
      for (final note in notes) {
        selectedNotes[note] = false;
        repaintKeys[note] = GlobalKey();
      }
    }
    setState(() => loading = false);
  }

  Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final completer = Completer<Uint8List?>();
      final overlay = Overlay.of(context);

      final entry = OverlayEntry(
        builder: (context) => Positioned(
          left: 0,
          top: 0,
          child: Material(
            color: Colors.transparent,
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: NoteVisual(
                  note: selectedNotes.keys
                      .firstWhere((n) => repaintKeys[n] == key),
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(entry);

      await Future.delayed(Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final renderObject = key.currentContext?.findRenderObject();

      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        print("Render object inválido");
        entry.remove();
        return null;
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      entry.remove();
      return bytes;
    } catch (e, stacktrace) {
      print("ERROR al capturar widget: $e");
      print("Stacktrace: $stacktrace");
      return null;
    }
  }

  Future<void> _exportAsImages() async {
    bool huboExito = false;

    for (final entry in selectedNotes.entries) {
      if (entry.value) {
        final key = repaintKeys[entry.key];
        if (key == null) continue;

        final bytes = await _captureWidget(key);
        if (bytes != null) {
          final title = entry.key.title?.replaceAll(" ", "_") ?? "nota";
          await FileServices.instance.saveBytes(
            "$title.png",
            bytes,
            folder: "Imágenes",
          );
          huboExito = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "⚠ No se pudo capturar la nota: ${entry.key.title ?? 'Sin título'}"),
              backgroundColor: Colors.red.shade300,
            ),
          );
        }
      }
    }

    if (huboExito) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Notas guardadas como imagen en carpeta Imágenes")),
      );
    }

    setState(() => selectedNotes.updateAll((key, _) => false));
  }

  Future<void> _shareImages() async {
    final selected =
        selectedNotes.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) return;

    final List<XFile> imagesToShare = [];

    for (final note in selected) {
      final key = repaintKeys[note];
      if (key == null) continue;

      final bytes = await _captureWidget(key);
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "No se pudo generar la imagen para compartir: ${note.title ?? 'Sin título'}"),
            backgroundColor: Colors.red.shade300,
          ),
        );
        continue;
      }
    }

    if (imagesToShare.isNotEmpty) {
      await Share.shareXFiles(
        imagesToShare,
        text: "Te comparto estas notas como imágenes",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No se pudo generar las imágenes para compartir")),
      );
    }

    setState(() => selectedNotes.updateAll((key, _) => false));
  }

  String _parseDate(String? date) {
    try {
      final _date = date?.split("-");
      if (_date == null || _date.length != 3) return "";

      final day = _date[0];
      final month = int.parse(_date[1]);
      final year = _date[2];

      if (month >= 1 && month <= 12) {
        return "$day de ${Constants.nameMonth[month]} del $year";
      } else {
        return date ?? "";
      }
    } catch (e) {
      return date ?? "";
    }
  }

  Widget _buildNotePreview(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeImage(
            path: note.image ?? "",
            width: 50,
            height: 50,
            radius: 8,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((note.title?.isNotEmpty ?? false))
                  Text(
                    note.title!,
                    style: TextStyle(
                      color: fontColor(),
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if ((note.description?.isNotEmpty ?? false))
                  Text(
                    note.description!,
                    style: TextStyle(
                      color: fontColor(),
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 4),
                Text(
                  _parseDate(note.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepOrange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: selectedNotes[note],
            onChanged: (value) {
              setState(() {
                selectedNotes[note] = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = ThemeController.instance.background();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text("Seleccionar notas", style: TextStyle(color: fontColor())),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: fontColor()),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: selectedNotes.keys
                            .map((note) => _buildNotePreview(note))
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  ThemeController.instance.primary(),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.download),
                            onPressed: _exportAsImages,
                            label: Text("Exportar"),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  ThemeController.instance.primary(),
                              foregroundColor: Colors.white,
                            ),
                            icon: Icon(Icons.share),
                            onPressed: _shareImages,
                            label: Text("Compartir"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: true,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: Offstage(
                    offstage: true,
                    child: Column(
                      children: selectedNotes.keys.map((note) {
                        return RepaintBoundary(
                          key: repaintKeys[note],
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Material(
                              color: Colors.transparent,
                              child: NoteVisual(note: note),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
