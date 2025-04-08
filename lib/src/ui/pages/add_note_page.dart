import 'dart:io';

import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/ui/widgets/buttons/simple_buttons.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class AddNotePageArguments {
  final bool edit;
  final bool private;
  final Note? note;
  AddNotePageArguments({this.edit = false, this.private = false, this.note});
}

final defaultArguments = AddNotePageArguments();

class AddNotePage extends StatelessWidget {
  const AddNotePage({Key? key}) : super(key: key);

  static final ADD_NOTE_PAGE_ROUTE = "add_note_page_route";

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.instance;
    AddNotePageArguments arguments;
    arguments = ModalRoute.of(context)?.settings.arguments != null
        ? ModalRoute.of(context)?.settings.arguments as AddNotePageArguments
        : defaultArguments;
    return Scaffold(
      backgroundColor: theme.background(),
      appBar: AppBar(
        title: Text(
          "Nueva Nota",
          style: TextStyle(color: fontColor()),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _Body(arguments),
    );
  }
}

class _Body extends StatefulWidget {
  final AddNotePageArguments arguments;
  const _Body(this.arguments, {Key? key}) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  late TextEditingController _title;
  late TextEditingController _description;

  String? image;

  final Note note = Note();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    if (widget.arguments.edit) {
      _title = TextEditingController(text: widget.arguments.note?.title ?? "");
      _description =
          TextEditingController(text: widget.arguments.note?.description ?? "");
    } else {
      _title = TextEditingController(text: "");
      _description = TextEditingController(text: "");
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextInput(
            title: "Título",
            controller: _title,
          ),
          LargeTextInput(
            title: "Descripción",
            controller: _description,
          ),
          image != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(image!),
                    leading: Icon(Icons.file_open_outlined),
                  ),
                )
              : SizedBox(),
          Row(
            children: [
              Flexible(
                child: MediumButton(
                  title: "Cámara",
                  icon: Icons.camera,
                  onTap: () async {
                    try {
                      final XFile? photo =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (photo != null)
                        setState(() {
                          image = photo.path;
                        });
                    } catch (e) {}
                  },
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: MediumButton(
                  title: "Galería",
                  icon: Icons.image,
                  onTap: () async {
                    try {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        File file = File(result.files.single.path!);
                        setState(() {
                          image = result.files.single.name;
                        });
                      }
                    } catch (e) {}
                  },
                  primaryColor: false,
                ),
              ),
            ],
          ),
          Spacer(),
          MediumButton(
            title: "Guardar",
            onTap: () {
              note.title = _title.value.text;
              note.description = _description.value.text;
              note.private = widget.arguments.private;
              if (image != null) {
                note.image = image;
                note.type = TypeNote.Image;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }
}
