import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class TrashPage extends StatelessWidget {
  TrashPage({Key? key}) : super(key: key);

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
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    _loadTrashNotes();
  }

  Future<void> _loadTrashNotes() async {
    final response = await FirebaseServices.instance.read("notes");
    if (response["status"] == StatusNetwork.Connected) {
      final allNotes = (response["data"] as List).cast<Note>();
      setState(() {
        notes = allNotes.where((note) => note.deleted == true).toList();
      });
    }
  }

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
          child: notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline,
                          size: 80, color: fontColor().withOpacity(0.3)),
                      SizedBox(height: 16),
                      Text(
                        "La papelera está vacía",
                        style: TextStyle(
                          fontSize: 18,
                          color: fontColor().withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(
                        note.title ?? "",
                        style: TextStyle(color: fontColor()),
                      ),
                      subtitle: Text(
                        note.description ?? "",
                        style: TextStyle(color: fontColor()),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton(
                        onSelected: (value) async {
                          if (value == 0) {
                            await FirebaseServices.instance
                                .update("notes", note.id!, {
                              "deleted": false,
                            });
                          }
                          if (value == 1) {
                            await FirebaseServices.instance
                                .delete("notes", note.id!);
                          }

                          setState(() {
                            notes.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value == 0
                                  ? "Nota restaurada"
                                  : "Nota eliminada permanentemente"),
                            ),
                          );
                        },
                        icon: Icon(Icons.more_vert, color: fontColor()),
                        itemBuilder: (context) => [
                          PopupMenuItem(child: Text("Restaurar"), value: 0),
                          PopupMenuItem(child: Text("Eliminar"), value: 1),
                        ],
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }
}
