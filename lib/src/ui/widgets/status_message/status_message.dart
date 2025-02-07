import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/ui/configure.dart';
import 'package:flutter/material.dart';

class StatusMessage extends StatelessWidget {
  final Function() onTap;
  final StatusNetwork status;

  StatusMessage(this.onTap, this.status, {Key? key}) : super(key: key);

  Color fontColor() =>
      !ThemeController.instance.brightnessValue ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            status == StatusNetwork.NoInternet
                ? "No Internet"
                : "No se pudo conectar a internet",
            style: TextStyle(
                color: fontColor(), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Configure.BACKGROUND_LIGHT,
                borderRadius: BorderRadius.circular(75)),
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(status == StatusNetwork.NoInternet
                          ? "assets/nointernet.png"
                          : "assets/error.png"))),
            ),
          ),
          Column(
            children: [
              Text(
                "Por favor, vuelva a intentar",
                style: TextStyle(color: fontColor()),
              ),
              TextButton(
                child: Text("Volver a intentar"),
                onPressed: onTap,
              )
            ],
          )
        ],
      ),
    );
  }
}
