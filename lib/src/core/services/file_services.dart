import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FileServices {
  FileServices._();
  static FileServices instance = FileServices._();

  void generatePDF(Note note) {
    final pdf = pw.Document();

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
          ]);
        }));
  }
}
