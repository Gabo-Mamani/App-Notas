import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/pages/add_attachment_page.dart';
import 'package:app_notas/src/ui/pages/add_note_page.dart';
import 'package:app_notas/src/ui/pages/error_page.dart';
import 'package:app_notas/src/ui/pages/export_notes_page.dart';
import 'package:app_notas/src/ui/pages/home_page.dart';
import 'package:app_notas/src/ui/pages/landing_page.dart';
import 'package:app_notas/src/ui/pages/list_notes_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/pages/private_notes.dart';
import 'package:app_notas/src/ui/pages/search_notes_pages.dart';
import 'package:app_notas/src/ui/pages/task_list_page.dart';
import 'package:app_notas/src/ui/pages/trash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as fc;

void main() async {
  ErrorWidget.builder =
      (FlutterErrorDetails details) => ErrorPage(details: details);
  WidgetsFlutterBinding.ensureInitialized();
  await fc.Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeController.instance.initTheme(),
      builder: (snapshot, context) {
        return MaterialApp(
          routes: {
            HomePage.HOME_PAGE_ROUTE: (context) => HomePage(),
            ErrorPage.ERROR_PAGE_ROUTE: (context) => ErrorPage(),
            LandingPage.LANDING_PAGE_ROUTE: (context) => LandingPage(),
            NotePage.NOTE_PAGE_ROUTE: (context) => NotePage(),
            NotePrivatePage.NOTE_PRIVATE_PAGE_ROUTE: (context) =>
                NotePrivatePage(),
            SearchNotesPage.SEARCH_NOTES_PAGE_ROUTE: (context) =>
                SearchNotesPage(),
            AddNotePage.ADD_NOTE_PAGE_ROUTE: (context) => AddNotePage(),
            AddAttachmentPage.ADD_ATTACHMENT_PAGE: (context) =>
                AddAttachmentPage(),
            ExportNotesPage.EXPORT_NOTES_PAGE_ROUTE: (context) =>
                ExportNotesPage(),
            TrashPage.TRASH_PAGE_ROUTE: (context) => TrashPage(),
            TaskListPage.TASK_LIST_PAGE_ROUTE: (context) => TaskListPage(),
            ListSimpleNotes.LIST_SIMPLE_NOTES_ROUTE: (context) =>
                ListSimpleNotes()
          },
          debugShowCheckedModeBanner: false, //Quitar barra debug
          title: Constants.mainTitle,
          initialRoute: LandingPage.LANDING_PAGE_ROUTE,
          theme: ThemeData(
            fontFamily: 'Roboto',
          ),
        );
      },
    );
  }
}
