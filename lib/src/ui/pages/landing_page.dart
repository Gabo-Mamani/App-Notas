import 'package:app_notas/src/core/constants/data.dart';
import 'package:app_notas/src/ui/pages/home_page.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget.dart';
import 'package:app_notas/src/ui/widgets/loading_widget/loading_widget_controller.dart';
import 'package:flutter/material.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  static final LANDING_PAGE_ROUTE = "landing_page";

  Widget _image() {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/landing.png"))));
  }

  Future<void> initMethods() async {}

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    return Stack(
      children: [
        ScaffoldMessenger(
          key: homePageMessengerKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: _image()),
                    Text(Constants.mainTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text(
                      Constants.subTitle,
                      style: TextStyle(color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 100),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MediumButton(
                          title: "Ingresar",
                          onTap: () async {
                            LoadingWidgetController.instance.loading();
                            await initMethods();
                            LoadingWidgetController.instance.close();
                            Navigator.pushNamed(
                                context, HomePage.HOME_PAGE_ROUTE);
                          }),
                    )
                  ],
                )),
          ),
        ),
        ValueListenableBuilder(
            valueListenable: LoadingWidgetController.instance.loadingNotifier,
            builder: (context, bool value, Widget? child) {
              return value ? LoadingWidget() : SizedBox();
            })
      ],
    );
  }
}
