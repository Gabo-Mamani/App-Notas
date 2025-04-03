import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/widgets/cards/custom_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

GlobalKey<ScaffoldState> notePrivatePageKey = GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldMessengerState> notePrivatePageMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Color fontColor() {
  return !ThemeController.instance.brightnessValue
      ? Colors.black
      : Colors.white;
}

class NotePrivatePage extends StatelessWidget {
  const NotePrivatePage({Key? key}) : super(key: key);
  static const NOTE_PRIVATE_PAGE_ROUTE = "note_private_home_page";

  Color background() {
    return ThemeController.instance.brightnessValue
        ? Configure.BACKGROUND_DARK
        : Configure.BACKGROUND_LIGHT;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;

    return Scaffold(
      backgroundColor: background(),
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

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

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
          child: StaggeredGridView.countBuilder(
            physics: BouncingScrollPhysics(),
            crossAxisCount: 2,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              if (notes[index].type == TypeNote.Text)
                return SimpleCard(
                  notes[index],
                  onTap: () => Navigator.pushNamed(
                      context, NotePage.NOTE_PAGE_ROUTE,
                      arguments: NotePageArguments(note: notes[index])),
                );
              if (notes[index].type == TypeNote.Image)
                return ImageCard(
                  notes[index],
                  onTap: () => Navigator.pushNamed(
                      context, NotePage.NOTE_PAGE_ROUTE,
                      arguments: NotePageArguments(note: notes[index])),
                );
              if (notes[index].type == TypeNote.TextImage)
                return TextImageCard(
                  notes[index],
                  onTap: () => Navigator.pushNamed(
                      context, NotePage.NOTE_PAGE_ROUTE,
                      arguments: NotePageArguments(note: notes[index])),
                );
              return Container();
            },
            staggeredTileBuilder: (int index) =>
                new StaggeredTile.count(1, index.isEven ? 1.3 : 1.9),
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
          ),
        )
      ],
    );
  }
}
