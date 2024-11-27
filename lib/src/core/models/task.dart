
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