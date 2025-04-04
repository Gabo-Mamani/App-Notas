import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class AddNotePage extends StatelessWidget {
  const AddNotePage({Key? key}) : super(key: key);

  static final ADD_NOTE_PAGE_ROUTE = "add_note_page_route";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Container(),
    );
  }
}
