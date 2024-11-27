import 'package:app_notas/src/core/constants/parameters.dart';

class Note {
  String? title;
  String? date;
  String? description;
  bool private;
  List<String>? urls;
  String? image;
  TypeNote type;
  StateNote state;


  Note({
    this.title,
    this.date,
    this.description,
    this.private = false,
    this.urls,
    this.image,
    this.type = TypeNote.Text,
    this.state = StateNote.Visible,
  });
}

Note note = Note(
  title: "Primer nota",
  date: "24-11-2024",
  description: "Mi primera chambaa",
);