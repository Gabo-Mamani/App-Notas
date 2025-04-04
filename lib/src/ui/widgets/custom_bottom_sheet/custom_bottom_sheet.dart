import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/services/preferences_service.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:app_notas/src/ui/pages/home_page.dart';
import 'package:app_notas/src/ui/pages/private_notes.dart';
import 'package:app_notas/src/ui/widgets/snackbars/custom_snackbars.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final Widget? content;
  final Function()? onTap;
  final Function()? close;

  CustomBottomSheet({Key? key, this.content, this.onTap, this.close})
      : super(key: key);

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  Color background() {
    return ThemeController.instance.brightnessValue
        ? Configure.BACKGROUND_DARK
        : Configure.BACKGROUND_LIGHT;
  }

  Color fontColor() {
    return !ThemeController.instance.brightnessValue
        ? Colors.black
        : Colors.white;
  }

  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = ThemeController.instance;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        height: size.height - 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: background(),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: widget.close,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.close),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 64, color: theme.primary()),
                      SizedBox(height: 8),
                      Text(
                        "Desbloquear Notas",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: theme.primary(),
                                fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Ingrese su contraseña",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: fontColor()),
                      ),
                      TextInput(controller: _controller, private: true),
                    ],
                  ),
                  CupertinoButton(
                    child: Text("Ingresar"),
                    onPressed: () async {
                      final password =
                          await PreferencesService.instance.getPassword();
                      if (password == _controller.value.text) {
                        Navigator.pushNamed(
                            context, NotePrivatePage.NOTE_PRIVATE_PAGE_ROUTE);
                        widget.close!();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("La Contraseña es incorrecta"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("Aceptar"),
                                )
                              ],
                            );
                          },
                        );
                      }
                    },
                    color: theme.primary(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
