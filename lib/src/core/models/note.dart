import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

TypeNote convertType(String value) {
  return TypeNote.values.firstWhere((element) => element.toString() == value);
}

StateNote convertState(String value) {
  return StateNote.values.firstWhere((element) => element.toString() == value);
}

class Note {
  String? title;
  String? date;
  String? description;
  bool private;
  List<String>? urls;
  String? image;
  TypeNote type;
  StateNote state;
  String? id;

  Note(
      {this.title,
      this.date,
      this.description,
      this.private = false,
      this.urls,
      this.image,
      this.type = TypeNote.Text,
      this.state = StateNote.Visible,
      this.id});

  factory Note.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    return Note(
        image: snapshot["image"],
        title: snapshot["title"],
        description: snapshot["description"],
        date: snapshot["date"],
        private: snapshot["private"],
        type: convertType(snapshot["type"]),
        state: convertState(snapshot["state"]),
        id: id);
  }

  void mostrar() {
    print(this.title);
    print(this.description);
  }
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
  description: "Hola, instagram https://www.instagram.com/?hl=es-la",
);

List<Note> notes = [
  note,
  note1,
  note2,
  note,
  note1,
  note2,
  note,
  note1,
  note2,
];
