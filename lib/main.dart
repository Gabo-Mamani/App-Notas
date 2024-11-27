import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/ui/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        HomePage.homePageRoute: (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false, //Quitar barra debug
      title: Constants.mainTitle,
      initialRoute: HomePage.homePageRoute,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }
}