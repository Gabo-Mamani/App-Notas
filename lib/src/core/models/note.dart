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
  bool deleted;
  List<String>? urls;
  String? image;
  TypeNote type;
  StateNote state;
  String? id;
  int? order;

  Note({
    this.title,
    this.date,
    this.description,
    this.private = false,
    this.deleted = false,
    this.urls,
    this.image,
    this.type = TypeNote.Text,
    this.state = StateNote.Visible,
    this.id,
    this.order,
  });

  factory Note.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    return Note(
      image: snapshot["image"],
      title: snapshot["title"],
      description: snapshot["description"],
      date: snapshot["date"],
      private: snapshot["private"],
      deleted:
          snapshot.data().containsKey("deleted") ? snapshot["deleted"] : false,
      type: convertType(snapshot["type"]),
      state: convertState(snapshot["state"]),
      id: id,
      order: snapshot.data().containsKey("order") ? snapshot["order"] : null,
    );
  }

  void mostrar() {
    print(this.title);
    print(this.description);
  }
}
