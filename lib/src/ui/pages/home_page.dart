// ignore_for_file: deprecated_member_use

import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/ui/widgets/buttons/card_button.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:app_notas/src/ui/widgets/cards/custom_cards.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/chek_tile.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/custom_tile.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget_controller.dart';
import 'package:app_notas/src/ui/widgets/snackbars/custom_snackbars.dart';
import 'package:app_notas/src/ui/widgets/status_message/status_message.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

GlobalKey<ScaffoldState> homePageKey = GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldMessengerState> homePageMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  static const homePageRoute = "home_page";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;

  @override
  void initState() {
    _controller1 = TextEditingController(text: "");
    _controller2 = TextEditingController(text: "");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: ThemeController.instance.brightness,
            builder: (BuildContext context, value, Widget? child) {
              final theme = ThemeController.instance;
              return ScaffoldMessenger(
                key: homePageMessengerKey,
                child: Scaffold(
                    backgroundColor: theme.background(),
                    key: homePageKey,
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Center(
                              child: Text(
                            "Hola",
                            style:
                                TextStyle(fontSize: 20, color: theme.primary()),
                          )),
                        ),
                        ElevatedButton(
                            onPressed: () => theme.changeTheme(),
                            child: Text("Acción")),
                        ElevatedButton(
                            onPressed: () async {
                              LoadingWidgetController.instance.loading();
                              LoadingWidgetController.instance
                                  .changeText("Está Cargando...");
                              await Future.delayed(Duration(seconds: 2));
                              LoadingWidgetController.instance.close();
                            },
                            child: Text("Loading")),
                        Container(
                            height: 350,
                            width: double.infinity,
                            child: StatusMessage(() async {
                              LoadingWidgetController.instance.loading();
                              LoadingWidgetController.instance
                                  .changeText("Está Cargando...");
                              await Future.delayed(Duration(seconds: 2));
                              LoadingWidgetController.instance.close();
                            }, StatusNetwork.Exception)),
                        // Row(
                        //   children: [
                        //     Flexible(child: SimpleCard(note)),
                        //     Flexible(child: ImageCard(note1)),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Flexible(child: SimpleCard(note)),
                        //     Flexible(child: TextImageCard(note2)),
                        //   ],
                        // ),
                        // ElevatedButton(
                        //     onPressed: () async {
                        //       if (await canLaunch(
                        //           "https://pub.dev/packages/url_launcher/example")) {
                        //         launch(
                        //             "https://pub.dev/packages/url_launcher/example");
                        //       }
                        //     },
                        //     child: Text("url")),
                        // MediumButton(
                        //   title: "Boton nuevo",
                        //   onTap: () =>
                        //       showSnackBar(homePageMessengerKey, "Hola Snackbar"),
                        // ),
                        // CardButton(
                        //   title: "PDF",
                        //   icon: Icons.book,
                        // ),
                        // TextInput(title: "entrada", controller: _controller1),
                        // LargeTextInput(title: "largo", controller: _controller2),
                        // ImageTile(
                        //   title: "Menu",
                        //   description: "Esta es la descripcion de nuestro tile",
                        // ),
                        // CheckTile(title: "Check")
                      ],
                    )),
              );
            }),
        ValueListenableBuilder(
            valueListenable: LoadingWidgetController.instance.loadingNotifier,
            builder: (context, bool value, Widget? child) {
              return value ? LoadingWidget() : SizedBox();
            })
      ],
    );
  }
}
