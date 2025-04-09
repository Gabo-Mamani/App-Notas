import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/file_services.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget_controller.dart';
import 'package:app_notas/src/ui/widgets/status_message/status_message.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class ListSimpleArguments {
  final Function()? action;
  final bool pdf;
  ListSimpleArguments({this.action, this.pdf = false});
}

class ListSimpleNotes extends StatefulWidget {
  ListSimpleNotes({Key? key}) : super(key: key);

  static final LIST_SIMPLE_NOTES_ROUTE = "list_simple_notes";

  @override
  _ListSimpleNotesState createState() => _ListSimpleNotesState();
}

class _ListSimpleNotesState extends State<ListSimpleNotes> {
  final FirebaseServices _services = FirebaseServices.instance;

  List<dynamic> notes = [];

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    final ListSimpleArguments args =
        ModalRoute.of(context)!.settings.arguments as ListSimpleArguments;
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
        bottom: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          title:
              Text("Seleccione la nota", style: TextStyle(color: fontColor())),
        ),
      ),
      body: FutureBuilder(
        future: _services.read("notes"),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StatusMessage(() async {
              await _services.read("notes");
            }, StatusNetwork.Exception);
          }
          if (!snapshot.hasData) {
            return LinearProgressIndicator();
          } else {
            Map<String, dynamic> response =
                snapshot.data as Map<String, dynamic>;
            if (response["status"] == StatusNetwork.Connected) {
              notes = response["data"];
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.note, color: fontColor()),
                    onTap: () async {
                      args.action!();
                      if (args.pdf) {
                        LoadingWidgetController.instance.loading();
                        await FileServices.instance.generatePDF(notes[index]);
                        LoadingWidgetController.instance.close();
                      } else {
                        Navigator.pushNamed(context, NotePage.NOTE_PAGE_ROUTE,
                            arguments: NotePageArguments(note: notes[index]));
                      }
                    },
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
              );
            } else {
              return StatusMessage(() async {}, StatusNetwork.Exception);
            }
          }
        },
      ),
    );
  }
}
