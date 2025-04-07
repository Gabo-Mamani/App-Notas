import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/task.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/chek_tile.dart';
import 'package:app_notas/src/ui/widgets/text_inputs/text_inputs.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class TaskListPage extends StatelessWidget {
  const TaskListPage({Key? key}) : super(key: key);

  static final TASK_LIST_PAGE_ROUTE = "task_list_page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  __BodyState createState() => __BodyState();
}

class __BodyState extends State<_Body> {
  late TextEditingController _controller;

  List<Task> task = tasks;

  @override
  void initState() {
    _controller = TextEditingController(text: "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Mis Tareas",
            style: TextStyle(color: fontColor(), fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: task.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return CheckTile(
                subtitle: task[index].description ?? "",
                title: task[index].title ?? "",
                PastDate: task[index].state == StateTask.PastDate,
                activate: task[index].state == StateTask.Done,
              );
            },
          ),
        ),
        TextInput(
          title: "Nueva Tarea",
          icon: Icons.add,
          action: () {},
        )
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
