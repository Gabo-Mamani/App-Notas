import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/pages/add_note_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/pages/search_notes_pages.dart';
import 'package:app_notas/src/ui/pages/trash_page.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet_controller.dart';
import 'package:app_notas/src/ui/widgets/status_message/status_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:app_notas/src/ui/widgets/cards/note_card.dart';

GlobalKey<ScaffoldState> homePageKey = GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldMessengerState> homePageMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<_BodyState> _bodyKey = GlobalKey<_BodyState>();

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const HOME_PAGE_ROUTE = "home_page";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late CustomBottomSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CustomBottomSheetController(this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: theme.primary(),
            child: Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AddNotePage.ADD_NOTE_PAGE_ROUTE,
              );
              if (result == true) {
                _bodyKey.currentState?._refresh();
              }
            },
          ),
          backgroundColor: theme.background(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: fontColor()),
                onPressed: () => Navigator.pop(context)),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.search, color: fontColor()),
                onPressed: () => Navigator.pushNamed(
                    context, SearchNotesPage.SEARCH_NOTES_PAGE_ROUTE),
              ),
              IconButton(
                icon: Icon(CupertinoIcons.delete_simple, color: fontColor()),
                onPressed: () =>
                    Navigator.pushNamed(context, TrashPage.TRASH_PAGE_ROUTE),
              ),
              IconButton(
                icon: Icon(Icons.brightness_6, color: fontColor()),
                tooltip: "Cambiar tema",
                onPressed: () {
                  ThemeController.instance.changeTheme();
                  setState(() {});
                },
              ),
            ],
          ),
          body: _Body(key: _bodyKey),
        ),
        Transform.translate(
          offset:
              Offset(0, size.height + 100 - (size.height * _controller.value)),
          child: CustomBottomSheet(close: () {
            _controller.close();
          }),
        )
      ],
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _services = FirebaseServices.instance;
  List<dynamic> notes = [];
  int? draggingIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    final response = await _services.read("notes");
    if (response["status"] == StatusNetwork.Connected) {
      final allNotes = (response["data"] as List).cast<Note>();
      notes = allNotes.where((note) => note.private != true).toList()
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    }
    setState(() => isLoading = false);
  }

  void _refresh() {
    _loadNotes();
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
            "Notas",
            style: TextStyle(color: fontColor(), fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : StaggeredGridView.countBuilder(
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return LongPressDraggable(
                      data: index,
                      onDragStarted: () =>
                          setState(() => draggingIndex = index),
                      onDragEnd: (_) => setState(() => draggingIndex = null),
                      feedback: Material(
                        color: Colors.transparent,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            width: 160,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeController.instance
                                  .primary()
                                  .withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 8)
                              ],
                            ),
                            child: Text(
                              note.title ?? "Nota",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: DragTarget<int>(
                        onAccept: (fromIndex) async {
                          setState(() {
                            final movedNote = notes.removeAt(fromIndex);
                            notes.insert(index, movedNote);
                          });

                          for (int i = 0; i < notes.length; i++) {
                            await _services
                                .update("notes", notes[i].id!, {"order": i});
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Orden actualizado")),
                          );
                        },
                        onWillAccept: (fromIndex) => fromIndex != index,
                        builder: (context, candidateData, rejectedData) {
                          return Opacity(
                            opacity: draggingIndex == index ? 0.5 : 1.0,
                            child: NoteCard(
                              note,
                              onTap: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  NotePage.NOTE_PAGE_ROUTE,
                                  arguments: NotePageArguments(note: note),
                                );
                                if (result == true) _refresh();
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      StaggeredTile.count(1, index.isEven ? 1.3 : 1.9),
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                ),
        ),
      ],
    );
  }
}
