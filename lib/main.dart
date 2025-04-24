import 'dart:async';
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
import 'package:app_notas/src/ui/pages/select_notes_image_page.dart';
import 'package:app_notas/src/ui/pages/select_notes_page.dart';
import 'package:app_notas/src/ui/pages/task_list_page.dart';
import 'package:app_notas/src/ui/pages/trash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' as fc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await fc.Firebase.initializeApp();

  // Captura de errores sincronizados
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(details.exception, details.stack!);
  };

  // Captura de errores asíncronos globales
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    runApp(MaterialApp(
      home: ErrorPage(
          details: FlutterErrorDetails(exception: error, stack: stackTrace)),
    ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThemeController.instance.initTheme(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Constants.mainTitle,
          theme: ThemeData(fontFamily: 'Roboto'),
          initialRoute: LandingPage.LANDING_PAGE_ROUTE,
          routes: {
            HomePage.HOME_PAGE_ROUTE: (_) => HomePage(),
            ErrorPage.ERROR_PAGE_ROUTE: (_) => ErrorPage(),
            LandingPage.LANDING_PAGE_ROUTE: (_) => LandingPage(),
            NotePage.NOTE_PAGE_ROUTE: (_) => NotePage(),
            NotePrivatePage.NOTE_PRIVATE_PAGE_ROUTE: (_) => NotePrivatePage(),
            SearchNotesPage.SEARCH_NOTES_PAGE_ROUTE: (_) => SearchNotesPage(),
            AddNotePage.ADD_NOTE_PAGE_ROUTE: (_) => AddNotePage(),
            AddAttachmentPage.ADD_ATTACHMENT_PAGE: (_) => AddAttachmentPage(),
            ExportNotesPage.EXPORT_NOTES_PAGE_ROUTE: (_) => ExportNotesPage(),
            TrashPage.TRASH_PAGE_ROUTE: (_) => TrashPage(),
            TaskListPage.TASK_LIST_PAGE_ROUTE: (_) => TaskListPage(),
            ListSimpleNotes.LIST_SIMPLE_NOTES_ROUTE: (_) => ListSimpleNotes(),
            SelectNotesPage.SELECT_NOTES_PAGE_ROUTE: (_) => SelectNotesPage(),
            SelectNotesImagePage.SELECT_NOTES_IMAGE_ROUTE: (_) =>
                SelectNotesImagePage(),
          },
        );
      },
    );
  }
}
