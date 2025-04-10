import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_notas/src/core/models/task.dart';
import 'package:app_notas/src/core/constants/parameters.dart';

class TaskService {
  static final TaskService instance = TaskService._();
  TaskService._();

  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection("tasks");

  Future<List<Task>> getTasks() async {
    final querySnapshot = await _collection.get();
    return querySnapshot.docs
        .map((doc) => Task.fromSnapshot(doc, doc.id))
        .toList();
  }

  Future<void> addTask(Task task) async {
    await _collection.add({
      "title": task.title,
      "description": task.description,
      "state": task.state.toString(),
      "date": task.date ?? _formatDate(DateTime.now()),
    });
  }

  Future<void> updateTaskState(String id, StateTask state) async {
    await _collection.doc(id).update({"state": state.toString()});
  }

  Future<void> deleteTask(String id) async {
    await _collection.doc(id).delete();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }
}
