import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class CheckTile extends StatefulWidget {
  final String title;
  bool? activate;
  final Function(bool)? onChanged;
  CheckTile({Key? key, this.title = "", this.activate = false, this.onChanged}) : super(key: key);

  @override
  State<CheckTile> createState() => _CheckTileState();
}

class _CheckTileState extends State<CheckTile> {

    Color getColorText() {
    return ThemeController.instance.brightnessValue 
    ? Colors.black
    :Colors.white;
  }

  @override
Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Checkbox(
          checkColor: getColorText(),
          activeColor: getColorText(),
          value: widget.activate, 
          onChanged: (value){
          setState(() {
            widget.activate = value;
          });
        }),
        SizedBox(width: 8),
        Expanded(
          child: Container(
          height: 50,
          child: Center(
            child: Text(
            widget.title, 
            style: TextStyle(color:getColorText(), fontSize: 16),),
          ),
            ),
        )
        ],
      ),
    );
}}