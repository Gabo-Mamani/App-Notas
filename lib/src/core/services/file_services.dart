import 'dart:io';
import 'dart:typed_data';
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

  Future<File?> saveBytes(String name, Uint8List bytes) async {
    File? aux_file;
    try {
      aux_file = File(await getPath(name));
      aux_file.writeAsBytesSync(bytes);
      return aux_file;
    } catch (e) {}
    return aux_file;
  }

  pw.Widget _image(File image) {
    return pw.Container(
      height: 100,
      width: double.infinity,
      decoration: pw.BoxDecoration(
          image: pw.DecorationImage(
              image: pw.MemoryImage(image.readAsBytesSync()),
              fit: pw.BoxFit.cover)),
    );
  }

  Future<void> generatePDF(Note note) async {
    try {
      File? aux_file;
      final pdf = pw.Document();

      if (note.image != null) {
        aux_file = await saveImage("aux_image.png", note.image!);
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
              pw.Divider(),
              pw.Text(note.description ?? ""),
              aux_file != null ? _image(aux_file) : pw.SizedBox()
            ]);
          }));

      final document = File(await getPath("Nota_vacia.pdf"));
      document.writeAsBytes(await pdf.save());
    } catch (e) {}
  }
}
