import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class CheckTile extends StatefulWidget {
  final String title;
  final String subtitle;
  bool? PastDate;
  bool? activate;
  final Function(bool)? onChanged;
  CheckTile(
      {Key? key,
      this.title = "",
      this.activate = false,
      this.onChanged,
      this.PastDate = false,
      this.subtitle = ""})
      : super(key: key);

  @override
  State<CheckTile> createState() => _CheckTileState();
}

class _CheckTileState extends State<CheckTile> {
  Color getColorText() {
    return ThemeController.instance.brightnessValue
        ? Colors.black
        : Colors.white;
  }

  Color getColorActive() {
    return !ThemeController.instance.brightnessValue
        ? Colors.black
        : Colors.white;
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
              activeColor: ThemeController.instance.background(),
              value: widget.activate,
              onChanged: (value) {
                setState(() {
                  widget.activate = value;
                });
              }),
          SizedBox(width: 8),
          Expanded(
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(color: getColorText(), fontSize: 16),
                ),
                Text(
                  widget.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: getColorText(), fontSize: 12),
                ),
                widget.PastDate!
                    ? Text(
                        "La fecha de la tarea expiró",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      )
                    : SizedBox(),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
