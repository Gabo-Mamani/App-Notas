import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/pages/select_notes_image_page.dart';
import 'package:app_notas/src/ui/pages/select_notes_page.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class ExportNotesPage extends StatelessWidget {
  const ExportNotesPage({Key? key}) : super(key: key);

  static final EXPORT_NOTES_PAGE_ROUTE = "export_notes_page";

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
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  Widget _card(String title, IconData icon, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(
              icon,
              color: fontColor(),
              size: 32,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: fontColor(), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/document.png")),
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Comparte y exporta notas",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: fontColor()),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 1,
                      child: _card(
                        "Exporta varias\nnotas en PDF",
                        Icons.note,
                        () => Navigator.pushNamed(
                          context,
                          SelectNotesPage.SELECT_NOTES_PAGE_ROUTE,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: _card(
                        "Exporta varias\nnotas en imagen",
                        Icons.image_outlined,
                        () => Navigator.pushNamed(
                          context,
                          SelectNotesImagePage.SELECT_NOTES_IMAGE_ROUTE,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
