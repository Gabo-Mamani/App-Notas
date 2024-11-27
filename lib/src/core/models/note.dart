class Note {
  String? title;
  String? date;
  String? description;
  bool private;
  List<String>? urls;
  String? image;
  
  Note({
    this.title,
    this.date,
    this.description,
    this.private = false,
    this.urls,
    this.image,
  });
}

Note note = Note(
  title: "Primer nota",
  date: "24-11-2024",
  description: "Mi primera chambaa",
);