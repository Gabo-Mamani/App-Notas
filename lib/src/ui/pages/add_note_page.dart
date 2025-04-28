import 'dart:io';

import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/services/cloudinary_service.dart';
import 'package:app_notas/src/core/services/file_services.dart';
import 'package:app_notas/src/core/services/firebase_services.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          arguments.edit ? "Edición de nota" : "Nueva Nota",
          style: TextStyle(color: fontColor()),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: fontColor()),
          onPressed: () => Navigator.pop(context),
        ),
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
  Note note = Note();
  final ImagePicker _picker = ImagePicker();
  final FirebaseServices _services = FirebaseServices.instance;

  bool _saving = false;

  String parseDate() {
    final date = DateTime.now();
    return "${date.day}-${date.month}-${date.year}";
  }

  Widget _buildImage() {
    final currentImage = image ?? note.image;

    if (currentImage == null || currentImage.trim().isEmpty) {
      return Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
    }

    if (currentImage.startsWith('http')) {
      return Image.network(
        currentImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
      );
    } else {
      final file = File(currentImage);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
        );
      } else {
        return Center(
            child: Icon(Icons.broken_image, size: 48, color: Colors.grey));
      }
    }
  }

  @override
  void initState() {
    if (widget.arguments.edit) {
      _title = TextEditingController(text: widget.arguments.note?.title ?? "");
      _description =
          TextEditingController(text: widget.arguments.note?.description ?? "");
      note = widget.arguments.note!;
    } else {
      _title = TextEditingController(text: "");
      _description = TextEditingController(text: "");
    }
    super.initState();
  }

  void _deleteImage() {
    setState(() {
      image = null;
      if (widget.arguments.edit) {
        note.image = null;
        note.type = TypeNote.Text;
      }
    });
  }

  Future<void> _saveNote() async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });

    try {
      note.title = _title.value.text;
      note.description = _description.value.text;
      note.private = widget.arguments.private;

      if (image != null) {
        final url = await CloudinaryService.uploadImage(File(image!));
        if (url != null) {
          note.image = url;
          note.type = TypeNote.ImagenNetwork;
        } else {
          note.image = image;
          note.type = TypeNote.Image;
        }
      } else if (widget.arguments.edit && note.image != null) {
        note.type = note.type ?? TypeNote.Image;
      }

      final Map<String, dynamic> values = {
        "date": parseDate(),
        "description": note.description,
        "image": note.image ?? "",
        "private": note.private,
        "state": note.state.toString(),
        "title": note.title,
        "type": note.type.toString(),
      };

      final Map<String, dynamic> response;
      if (widget.arguments.edit) {
        response = await _services.update("notes", note.id!, values);
      } else {
        final existingNotes = await FirebaseServices.instance.read("notes");
        if (existingNotes["status"] == StatusNetwork.Connected) {
          final List<dynamic> allNotes = existingNotes["data"];
          for (int i = 0; i < allNotes.length; i++) {
            final note = allNotes[i];
            await FirebaseServices.instance.update("notes", note.id!, {
              "order": (note.order ?? i) + 1,
            });
          }
        }
        values["order"] = 0;
        values["deleted"] = false;
        response = await _services.create("notes", values);
      }

      switch (response["status"]) {
        case StatusNetwork.Connected:
          if (widget.arguments.edit) {
            Navigator.pop(context, "edit");
          } else {
            Navigator.pop(context, true);
          }
          break;
        default:
          print("Error al guardar nota");
          break;
      }
    } catch (e) {
      print("Error durante el guardado: $e");
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextInput(
                            title: "Título",
                            controller: _title,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          LargeTextInput(
                            title: "Descripción",
                            controller: _description,
                          ),
                          if (image != null ||
                              (widget.arguments.edit && note.image != null))
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _buildImage(),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: _deleteImage,
                                      icon: Icon(Icons.delete,
                                          color: Colors.redAccent),
                                      tooltip: "Eliminar imagen",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Flexible(
                                child: MediumButton(
                                  title: "Cámara",
                                  icon: Icons.camera,
                                  onTap: () async {
                                    try {
                                      final XFile? photo =
                                          await _picker.pickImage(
                                        source: ImageSource.camera,
                                      );
                                      if (photo != null) {
                                        setState(() {
                                          image = photo.path;
                                        });
                                      }
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
                                        File file =
                                            File(result.files.single.path!);
                                        File? savedFile = await FileServices
                                            .instance
                                            .saveBytes(
                                          result.files.single.name,
                                          await file.readAsBytes(),
                                        );
                                        if (savedFile != null) {
                                          setState(() {
                                            image = savedFile.path;
                                          });
                                        }
                                      }
                                    } catch (e) {
                                      print(
                                          "Error al guardar imagen local: $e");
                                    }
                                  },
                                  primaryColor: false,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPadding(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.only(
                  bottom: viewInsets > 0 ? viewInsets : 8.0,
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                ),
                curve: Curves.easeOut,
                child: MediumButton(
                  title: _saving ? "Guardando..." : "Guardar",
                  onTap: _saving ? null : _saveNote,
                ),
              ),
            ],
          );
        },
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
