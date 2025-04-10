import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/pages/add_attachment_page.dart';
import 'package:app_notas/src/ui/pages/export_notes_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/pages/task_list_page.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet_controller.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/custom_tile.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';

import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

GlobalKey<ScaffoldState> searchNotesPageKey = GlobalKey<ScaffoldState>();

class SearchNotesPage extends StatelessWidget {
  const SearchNotesPage({Key? key}) : super(key: key);

  static final SEARCH_NOTES_PAGE_ROUTE = "search_notes_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeController.instance.background(),
        key: searchNotesPageKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: fontColor()),
              onPressed: () => Navigator.pop(context)),
        ),
        body: _Body());
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late CustomBottomSheetController _controller;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: "");
    _controller = CustomBottomSheetController(this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: TextInput(
                action: () {},
                icon: Icons.search,
                title: "Buscar nota",
                controller: _textController,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        "Sugerencias",
                        style: TextStyle(
                            color: fontColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        SimpleTile(
                          title: "Notas compratidas",
                          leading: Icons.share,
                          onTap: () => Navigator.pushNamed(
                              context, ExportNotesPage.EXPORT_NOTES_PAGE_ROUTE),
                        ),
                        SimpleTile(
                          title: "Tareas",
                          leading: Icons.task,
                          onTap: () => Navigator.pushNamed(
                              context, TaskListPage.TASK_LIST_PAGE_ROUTE),
                        ),
                        SimpleTile(
                          title: "Notas privadas",
                          leading: Icons.lock,
                          onTap: () => _controller.open(),
                        ),
                        SimpleTile(
                          title: "Recursos",
                          leading: Icons.image,
                          onTap: () => Navigator.pushNamed(
                              context, AddAttachmentPage.ADD_ATTACHMENT_PAGE),
                        )
                      ],
                    ),
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        "Recientes",
                        style: TextStyle(
                            color: fontColor(), fontWeight: FontWeight.bold),
                      ),
                    ),
                    FutureBuilder(
                      future: FirebaseServices.instance.read("notes"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData || snapshot.hasError) {
                          return Text(
                              "No se pudieron cargar las notas recientes");
                        }

                        final response = snapshot.data as Map<String, dynamic>;
                        if (response["status"] != StatusNetwork.Connected) {
                          return Text("No hay conexión");
                        }

                        List<dynamic> recentNotes = response["data"];
                        recentNotes.sort((a, b) =>
                            b.date.compareTo(a.date)); // Orden descendente

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              recentNotes.length < 3 ? recentNotes.length : 3,
                          itemBuilder: (context, index) {
                            final note = recentNotes[index];
                            return ImageTile(
                              onTap: () => Navigator.pushNamed(
                                context,
                                NotePage.NOTE_PAGE_ROUTE,
                                arguments: NotePageArguments(note: note),
                              ),
                              title: note.title ?? "",
                              description: note.description ?? "",
                              image: note.image ?? Constants.defaultImage,
                              date: note.date ?? "",
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        )),
        Transform.translate(
            offset:
                Offset(0, size.height + 20 - (size.height * _controller.value)),
            child: CustomBottomSheet(close: () {
              _controller.close();
            }))
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
