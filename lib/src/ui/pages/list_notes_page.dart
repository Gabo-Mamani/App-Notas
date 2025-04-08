import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class ListSimpleNotes extends StatelessWidget {
  const ListSimpleNotes({Key? key}) : super(key: key);

  static final LIST_SIMPLE_NOTES_ROUTE = "list_simple_notes";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () => Navigator.pushNamed(context, NotePage.NOTE_PAGE_ROUTE,
                arguments: NotePageArguments(note: notes[index])),
            title: Text(
              notes[index].title ?? "",
              style: TextStyle(color: fontColor()),
            ),
            subtitle: Text(
              notes[index].description ?? "",
              style: TextStyle(color: fontColor()),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
