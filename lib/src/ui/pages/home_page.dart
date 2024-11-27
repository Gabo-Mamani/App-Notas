import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:flutter/material.dart';

GlobalKey<ScaffoldState> homePageKey = GlobalKey<ScaffoldState>();

class HomePage extends StatelessWidget {
  const HomePage({ Key? key }) : super(key: key);
  static const homePageRoute = "home_page";

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
                      "Hola mundo",
                      style: TextStyle(fontSize: 20, color: theme.primary()),
                  )),
            ),
            ElevatedButton(onPressed: (){}, child: Text("Acción"))
          ],
        ));
    });
  }
}