import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app_notas/src/core/models/note.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as pp;
import 'package:http/http.dart' as http;

class FileServices {
  FileServices._();
  static FileServices instance = FileServices._();

  Future<String> getPath(String name) async {
    try {
      final path = await pp.getExternalStorageDirectories();

      if (path != null) {
        final String final_path = path.first.path + "/$name";
        return final_path;
      }
    } catch (e) {}
    return "";
  }

  Future<File?> saveImage(String name, String uri) async {
    File? aux_file;
    try {
      final response = await http.get(Uri.parse(uri));
      aux_file = File(await getPath(name));
      aux_file.writeAsBytesSync(response.bodyBytes);
      return aux_file;
    } catch (e) {}
    return aux_file;
  }

  Future<void> generatePDFMulti(List<Note> notes,
      {String fileName = "notas_exportadas.pdf",
      String folder = "Documentos"}) async {
    try {
      final pdf = pw.Document();

      for (final note in notes) {
        File? auxFile;
        if (note.image != null && note.image!.startsWith("http")) {
          auxFile = await saveImage("temp_image.png", note.image!);
        } else if (note.image != null && File(note.image!).existsSync()) {
          auxFile = File(note.image!);
        }

        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.letter,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(note.title ?? "Sin título",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(note.description ?? ""),
                pw.SizedBox(height: 8),
                auxFile != null ? imageWidget(auxFile) : pw.SizedBox(),
                pw.Divider(),
              ],
            );
          },
        ));
      }

      final path = await getPath(folder);
      final directory = Directory(path);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      int index = 1;
      String finalName = fileName;
      File file = File("$path/$finalName");

      while (file.existsSync()) {
        finalName = fileName.replaceAll(".pdf", "_$index.pdf");
        file = File("$path/$finalName");
        index++;
      }

      await file.writeAsBytes(await pdf.save());
    } catch (e) {
      print("Error al generar PDF múltiple: $e");
    }
  }

  Future<File?> saveBytes(String name, Uint8List bytes,
      {String folder = "Descargas"}) async {
    try {
      final path = await pp.getExternalStorageDirectories();
      if (path != null && path.isNotEmpty) {
        final directoryPath = "${path.first.path}/$folder";
        final directory = Directory(directoryPath);
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final filePath = "$directoryPath/$name";
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (e) {
      print("Error al guardar archivo: $e");
    }
    return null;
  }

  pw.Widget imageWidget(File image) {
    return pw.Container(
      height: 100,
      width: double.infinity,
      decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
              image: pw.MemoryImage(image.readAsBytesSync()),
              fit: pw.BoxFit.cover)),
    );
  }

  Future<void> generatePDF(Note note,
      {String fileName = "Nota.pdf", String folder = "Documentos"}) async {
    try {
      File? aux_file;
      final pdf = pw.Document();

      if (note.image != null && note.image!.startsWith("http")) {
        aux_file = await saveImage("aux_image.png", note.image!);
      } else if (note.image != null && File(note.image!).existsSync()) {
        aux_file = File(note.image!);
      }

      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.Column(children: [
            pw.Text(note.title ?? "Nota sin título",
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF000000))),
            pw.SizedBox(height: 12),
            pw.Text(note.description ?? ""),
            pw.SizedBox(height: 12),
            aux_file != null ? imageWidget(aux_file) : pw.SizedBox(),
          ]);
        },
      ));

      final path = await pp.getExternalStorageDirectories();
      if (path != null && path.isNotEmpty) {
        final directoryPath = "${path.first.path}/$folder";
        final directory = Directory(directoryPath);
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final filePath = "$directoryPath/$fileName";
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
      }
    } catch (e) {
      print("Error al generar PDF: $e");
    }
  }
}
