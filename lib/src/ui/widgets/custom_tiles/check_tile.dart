import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:flutter/material.dart';

class CheckTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? date;
  bool? PastDate;
  bool? activate;
  final Function(bool)? onChanged;
  final Widget? trailing;

  CheckTile({
    Key? key,
    this.title = "",
    this.subtitle = "",
    this.date,
    this.PastDate = false,
    this.activate = false,
    this.onChanged,
    this.trailing,
  }) : super(key: key);

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
              if (widget.onChanged != null) widget.onChanged!(value!);
            },
          ),
          SizedBox(width: 8),
          Expanded(
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
                if (widget.date != null)
                  Text(
                    "Fecha límite: ${widget.date}",
                    style: TextStyle(
                      color: widget.PastDate == true
                          ? Colors.red
                          : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: widget.trailing!,
            ),
        ],
      ),
    );
  }
}
