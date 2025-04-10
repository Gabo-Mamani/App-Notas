import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/controllers/theme_controller.dart';
import 'package:app_notas/src/core/models/task.dart';
import 'package:app_notas/src/core/services/task_service.dart';
import 'package:app_notas/src/ui/widgets/custom_tiles/check_tile.dart';
import 'package:flutter/material.dart';

Color fontColor() {
  return ThemeController.instance.brightnessValue ? Colors.black : Colors.white;
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);
  static final TASK_LIST_PAGE_ROUTE = "task_list_page";

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskService.instance.getTasks();

    for (var task in tasks) {
      if (_isPastDate(task.date) && task.state != StateTask.PastDate) {
        await TaskService.instance
            .updateTaskState(task.id!, StateTask.PastDate);
        task.state = StateTask.PastDate;
      }
    }

    setState(() {
      _tasks = tasks;
    });
  }

  bool _isPastDate(String? dateString) {
    if (dateString == null) return false;
    try {
      final parts = dateString.split("-");
      if (parts.length != 3) return false;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final taskDate = DateTime(year, month, day);
      final now = DateTime.now();

      return taskDate.isBefore(DateTime(now.year, now.month, now.day));
    } catch (e) {
      return false;
    }
  }

  Future<void> _addTask(
      String title, String description, DateTime? date) async {
    final task = Task(
      title: title,
      description: description,
      date: date != null ? "${date.day}-${date.month}-${date.year}" : null,
    );
    await TaskService.instance.addTask(task);
    _loadTasks();
  }

  void _showAddTaskSheet() {
    final _title = TextEditingController();
    final _description = TextEditingController();
    DateTime? _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 16,
              left: 16,
              right: 16),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(labelText: "Título"),
                  ),
                  TextField(
                    controller: _description,
                    decoration: InputDecoration(labelText: "Descripción"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: now.add(Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                        child: Text(_selectedDate == null
                            ? "Seleccionar fecha límite"
                            : "Fecha: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _addTask(
                          _title.text, _description.text, _selectedDate);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.save),
                    label: Text("Guardar"),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeController.instance.background(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: fontColor()),
            onPressed: () => Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: Icon(Icons.add),
      ),
      body: Column(
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
            child: _tasks.isEmpty
                ? Center(
                    child: Text("Sin tareas",
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Column(
                        children: [
                          CheckTile(
                            subtitle: task.description ?? "",
                            title: task.title ?? "",
                            date: task.date,
                            PastDate: task.state == StateTask.PastDate,
                            activate: task.state == StateTask.Done,
                            onChanged: (value) async {
                              final newState =
                                  value ? StateTask.Done : StateTask.Create;
                              await TaskService.instance
                                  .updateTaskState(task.id!, newState);
                              _loadTasks();
                            },
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              tooltip: "Eliminar tarea",
                              onPressed: () async {
                                await TaskService.instance.deleteTask(task.id!);
                                _loadTasks();
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
