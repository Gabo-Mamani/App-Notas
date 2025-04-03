import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotePageArguments {
  final Note? note;
  NotePageArguments({this.note});
}

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class NotePage extends StatelessWidget {
  final Note? note;
  NotePage({Key? key, this.note}) : super(key: key);

  static const NOTE_PAGE_ROUTE = "note_page";

  String _title(Note note) {
    if (note.title != null) {
      return note.title!;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    NotePageArguments arguments =
        ModalRoute.of(context)?.settings.arguments as NotePageArguments;
    final theme = ThemeController.instance;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeController.instance.primary(),
        onPressed: () {},
        child: Icon(Icons.edit),
      ),
      backgroundColor: theme.background(),
      appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            _title(arguments.note!),
            style: TextStyle(color: fontColor()),
          ),
          actions: [
            IconButton(
                onPressed: () {}, icon: Icon(Icons.delete, color: fontColor()))
          ]),
      body: _Body(arguments.note!),
    );
  }
}

class _Body extends StatelessWidget {
  final Note note;

  const _Body(this.note, {Key? key}) : super(key: key);

  Widget _image() {
    if (note.type == TypeNote.Image ||
        note.type == TypeNote.ImagenNetwork ||
        note.type == TypeNote.TextImage ||
        note.type == TypeNote.TextImageNetwork) {
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(note.image ?? Constants.defaultImage),
                fit: BoxFit.cover)),
      );
    }
    return Container();
  }

  void urls(String text) {
    note.urls = [];
    RegExp regexp =
        RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> match = regexp.allMatches(text);
    match.forEach((element) {
      note.urls?.add(text.substring(element.start, element.end));
    });
  }

  @override
  Widget build(BuildContext context) {
    urls(note.description ?? "");
    return Container(
      child: Column(
        children: [
          _image(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              note.description ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: fontColor()),
            ),
          ),
          Divider(),
          Expanded(
              child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: note.urls!.length,
            itemBuilder: (context, index) {
              final url = note.urls![index];
              return ListTile(
                onTap: () {
                  launch(url);
                },
                title: Text(url,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.blue)),
              );
            },
          ))
        ],
      ),
    );
  }
}
