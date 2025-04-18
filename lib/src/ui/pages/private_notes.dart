import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:app_notas/src/ui/pages/add_note_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/widgets/cards/note_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

final GlobalKey<_PrivateBodyState> _privateBodyKey =
    GlobalKey<_PrivateBodyState>();

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class NotePrivatePage extends StatefulWidget {
  const NotePrivatePage({Key? key}) : super(key: key);
  static const NOTE_PRIVATE_PAGE_ROUTE = "note_private_home_page";

  @override
  State<NotePrivatePage> createState() => _NotePrivatePageState();
}

class _NotePrivatePageState extends State<NotePrivatePage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primary(),
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AddNotePage.ADD_NOTE_PAGE_ROUTE,
            arguments: AddNotePageArguments(private: true),
          );
          if (result == true) {
            _privateBodyKey.currentState?._refresh();
          }
        },
      ),
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _PrivateBody(key: _privateBodyKey),
    );
  }
}

class _PrivateBody extends StatefulWidget {
  const _PrivateBody({Key? key}) : super(key: key);

  @override
  State<_PrivateBody> createState() => _PrivateBodyState();
}

class _PrivateBodyState extends State<_PrivateBody> {
  final _services = FirebaseServices.instance;
  List<Note> notes = [];
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
      notes = allNotes.where((note) => note.private == true).toList()
        ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    }
    setState(() => isLoading = false);
  }

  void _refresh() {
    _loadNotes();
  }

  Future<void> _updateOrderInFirebase() async {
    for (int i = 0; i < notes.length; i++) {
      await _services.update("notes", notes[i].id!, {"order": i});
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
            "Mis Notas Privadas",
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

                          await _updateOrderInFirebase();

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
