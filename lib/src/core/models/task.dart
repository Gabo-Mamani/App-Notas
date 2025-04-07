import 'package:app_notas/src/core/constants/parameters.dart';

class Task {
  String? title;
  String? date;
  String? description;
  List<String>? urls;
  StateTask state;

  Task({
    this.title,
    this.date,
    this.description,
    this.urls,
    this.state = StateTask.Create,
  });
}

Task task = Task(
    title: "Realizar compras",
    description: "Esta es una tarea",
    date: "12-04-2025");
Task task2 = Task(
    title: "Realizar tarea",
    description: "Esta es una tarea",
    date: "12-04-2025",
    state: StateTask.Done);
Task task3 = Task(
    title: "Realizar proyecto",
    description: "Esta es una tarea",
    date: "01-04-2025",
    state: StateTask.PastDate);

List<Task> tasks = [task, task2, task3];
