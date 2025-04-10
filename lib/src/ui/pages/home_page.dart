import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
import 'package:app_notas/src/ui/pages/add_note_page.dart';
import 'package:app_notas/src/ui/pages/error_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/pages/search_notes_pages.dart';
import 'package:app_notas/src/ui/pages/trash_page.dart';
import 'package:app_notas/src/ui/widgets/buttons/card_button.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:app_notas/src/ui/widgets/cards/custom_cards.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet.dart';
import 'package:app_notas/src/ui/widgets/custom_bottom_sheet/custom_bottom_sheet_controller.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/check_tile.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/custom_tile.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget_controller.dart';
import 'package:app_notas/src/ui/widgets/snackbars/custom_snackbars.dart';
import 'package:app_notas/src/ui/widgets/status_message/status_message.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_notas/src/ui/widgets/cards/note_card.dart';

GlobalKey<ScaffoldState> homePageKey = GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldMessengerState> homePageMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("¡Nota guardada exitosamente!")),
                  );
                });
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
          body: _Body(),
        ),
        Transform.translate(
            offset: Offset(
                0, size.height + 100 - (size.height * _controller.value)),
            child: CustomBottomSheet(close: () {
              _controller.close();
            }))
      ],
    );
  }
}

class _Body extends StatefulWidget {
  _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  FirebaseServices _services = FirebaseServices.instance;

  List<dynamic> notes = [];

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
            child: FutureBuilder(
          future: _services.read("notes"),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return StatusMessage(() async {
                await _services.read("notes");
              }, StatusNetwork.Exception);
            }
            if (!snapshot.hasData) {
              return Container();
            } else {
              Map<String, dynamic> response =
                  snapshot.data as Map<String, dynamic>;
              if (response["status"] == StatusNetwork.Connected) {
                notes = response["data"];
                return StaggeredGridView.countBuilder(
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return NoteCard(
                      notes[index],
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          NotePage.NOTE_PAGE_ROUTE,
                          arguments: NotePageArguments(note: notes[index]),
                        );

                        if (result == true) {
                          setState(() {});
                        }
                      },
                    );
                  },
                  staggeredTileBuilder: (int index) =>
                      new StaggeredTile.count(1, index.isEven ? 1.3 : 1.9),
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                );
              } else {
                return StatusMessage(() async {
                  await _services.read("notes");
                }, StatusNetwork.Exception);
              }
            }
          },
        )),
      ],
    );
  }
}
