import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class TrashPage extends StatelessWidget {
  const TrashPage({Key? key}) : super(key: key);

  static final TRASH_PAGE_ROUTE = "trash_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  List<Note> notes = [note1];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Papelera",
            style: TextStyle(color: fontColor(), fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
            child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      notes[index].title ?? "",
                      style: TextStyle(color: fontColor()),
                    ),
                    subtitle: Text(
                      notes[index].description ?? "",
                      style: TextStyle(color: fontColor()),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == 0) {
                          // restaurar elemento
                        }
                        if (value == 1) {
                          // eliminar elemento
                        }
                      },
                      icon: Icon(Icons.more_vert, color: fontColor()),
                      itemBuilder: (context) => [
                        PopupMenuItem(child: Text("Restaurar"), value: 0),
                        PopupMenuItem(child: Text("Eliminar"), value: 1),
                      ],
                    ),
                  );
                }))
      ],
    );
  }
}
