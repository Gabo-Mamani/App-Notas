import 'dart:io';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/ui/widgets/common/safe_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/services/file_services.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';

Color fontColor() =>
    ThemeController.instance.brightnessValue ? Colors.black : Colors.white;

class SelectNotesPage extends StatefulWidget {
  static const SELECT_NOTES_PAGE_ROUTE = "select_notes_page";

  const SelectNotesPage({super.key});

  @override
  State<SelectNotesPage> createState() => _SelectNotesPageState();
}

class _SelectNotesPageState extends State<SelectNotesPage> {
  final _services = FirebaseServices.instance;
  final Map<Note, bool> selectedNotes = {};
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
      }
    }
    setState(() => loading = false);
  }

  void _clearSelections() {
    setState(() {
      selectedNotes.updateAll((key, value) => false);
    });
  }

  Future<void> _exportAsPDF() async {
    final selected =
        selectedNotes.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) return;

    await FileServices.instance.generatePDFMulti(
      selected,
      fileName: "notas_exportadas.pdf",
      folder: "Documentos",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF guardado en carpeta Documentos")),
    );

    _clearSelections();
  }

  Future<void> _shareNotesAsPDF() async {
    final selected =
        selectedNotes.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) return;

    final filename = "notas_exportadas_compartidas.pdf";
    final folder = "Documentos";
    final path = await FileServices.instance.getPath(folder);
    final fullPath = "$path/$filename";
    final file = File(fullPath);

    await FileServices.instance
        .generatePDFMulti(selected, fileName: filename, folder: folder);

    if (await file.exists()) {
      Share.shareXFiles([XFile(file.path)],
          text: "Te comparto estas notas en PDF 📄");
      _clearSelections();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No se pudo encontrar el archivo para compartir")),
      );
    }
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
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: selectedNotes.keys.map((note) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        if ((note.description?.isNotEmpty ??
                                            false))
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
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeController.instance.primary(),
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.picture_as_pdf),
                        onPressed: _exportAsPDF,
                        label: Text("PDF"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeController.instance.primary(),
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.share),
                        onPressed: _shareNotesAsPDF,
                        label: Text("Compartir"),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
