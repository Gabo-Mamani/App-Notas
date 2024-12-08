// ignore_for_file: deprecated_member_use

import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/widgets/buttons/card_button.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/custom_tile.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

GlobalKey<ScaffoldState> homePageKey = GlobalKey<ScaffoldState>();

class HomePage extends StatefulWidget {
  HomePage({ Key? key }) : super(key: key);
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
    return ValueListenableBuilder(
      valueListenable: ThemeController.instance.brightness,
      builder: (BuildContext context, value, Widget? child) {
        final theme = ThemeController.instance;
        return Scaffold( 
            backgroundColor: theme.background(),
            key: homePageKey,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Center(
                    child: Text(
                      "Hola",
                      style: TextStyle(fontSize: 20, color: theme.primary()),
                  )),
            ),
            ElevatedButton(
              onPressed: ()=>theme.changeTheme(),
              child: Text("Acción")),
            ElevatedButton(
              onPressed: () async {
                if (await canLaunch(
                  "https://pub.dev/packages/url_launcher/example")) {
                    launch(
                      "https://pub.dev/packages/url_launcher/example");
                    }
                  },
                  child: Text("url")),
                  MediumButton(title: "Boton nuevo",
                  onTap: (){},
                  ),
                  CardButton(
                    title: "PDF",
                    icon: Icons.book,
                    ),
                  TextInput(
                    title: "entrada",
                    controller: _controller1
                  ),
                  LargeTextInput(
                    title: "largo",
                    controller: _controller2
                    ),
                    ImageTile(
                      title: "Menu",
                      description: "Esta es la descripcion de nuestro tile",
                    )
                ],
        ));
    });
  }
}