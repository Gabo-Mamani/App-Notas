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
  type: TypeNote.Text,
  description: "Hola, esta es una prueba",
);

Note note1 = Note(
  title: "Primer nota",
  date: "24-11-2024",
  type: TypeNote.Image,
  image:
      "https://img.freepik.com/vector-gratis/fondo-liso-estilo-papel_23-2148977880.jpg?semt=ais_hybrid",
  description: "Hola, esta es una prueba",
);

Note note2 = Note(
  title: "Primer nota",
  date: "24-11-2024",
  type: TypeNote.TextImage,
  image:
      "https://images.unsplash.com/photo-1655998233171-ee5b130acba5?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  description: "Hola, esta es una prueba",
);
