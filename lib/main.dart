import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/pages/error_page.dart';
import 'package:app_notas/src/ui/pages/home_page.dart';
import 'package:app_notas/src/ui/pages/landing_page.dart';
import 'package:app_notas/src/ui/pages/note_page.dart';
import 'package:app_notas/src/ui/pages/private_notes.dart';
import 'package:flutter/material.dart';

void main() {
  ErrorWidget.builder =
      (FlutterErrorDetails details) => ErrorPage(details: details);
  runApp(const MyApp());
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
