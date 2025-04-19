import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/core/services/file_services.dart';
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

  Future<void> _exportAsImages() async {
    for (final entry in selectedNotes.entries) {
      if (entry.value) {
        final key = repaintKeys[entry.key];
        if (key == null) continue;

        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) continue;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final bytes = byteData?.buffer.asUint8List();

        if (bytes != null) {
          final title = entry.key.title?.replaceAll(" ", "_") ?? "nota";
          await FileServices.instance.saveBytes(
            "$title.png",
            bytes,
            folder: "Imágenes",
          );
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("Notas guardadas como imagen en carpeta Imágenes")),
    );
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

      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) continue;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes != null) {
        final file = await FileServices.instance.saveBytes(
          "${note.title?.replaceAll(" ", "_") ?? "nota"}.png",
          bytes,
          folder: "Compartidas",
        );
        if (file != null) {
          imagesToShare.add(XFile(file.path));
        }
      }
    }

    if (imagesToShare.isNotEmpty) {
      await Share.shareXFiles(
        imagesToShare,
        text: "Te comparto estas notas como imágenes 🖼️",
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildNoteImage(note),
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

  Widget _buildNoteImage(Note note) {
    if (note.image != null && note.image!.trim().isNotEmpty) {
      try {
        final file = File(note.image!);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          );
        }
      } catch (_) {}
    }

    return Image.asset(
      "assets/default_note.png",
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _buildNoteFullRender(Note note) {
    return Container(
      width: 800,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (note.image != null && File(note.image!).existsSync())
            Image.file(
              File(note.image!),
              height: 200,
              fit: BoxFit.cover,
            ),
          SizedBox(height: 20),
          Text(
            note.title ?? "Sin título",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            note.description ?? "",
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            _parseDate(note.date),
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                Offstage(
                  child: Column(
                    children: selectedNotes.keys.map((note) {
                      return RepaintBoundary(
                        key: repaintKeys[note],
                        child: _buildNoteFullRender(note),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
