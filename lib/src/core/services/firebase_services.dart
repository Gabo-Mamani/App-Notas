import 'package:app_notas/src/core/constants/parameters.dart';
import 'package:app_notas/src/core/models/note.dart';
import 'package:app_notas/src/core/models/task.dart' as task;
import 'package:app_notas/src/core/services/interne_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices extends InterneServices {
  FirebaseServices._();
  static final instance = FirebaseServices._();

  final ref = FirebaseFirestore.instance;

  //Método crear
  Future<Map<String, dynamic>> create(
      String collection, Map<String, dynamic> data) async {
    Map<String, dynamic> dataResponse = {};
    if (await super.connected()) {
      try {
        await ref.collection(collection).add(data);
        dataResponse["status"] = StatusNetwork.Connected;
      } catch (e) {
        dataResponse["status"] = StatusNetwork.Exception;
      }
    } else {
      dataResponse["status"] = StatusNetwork.NoInternet;
    }
    return dataResponse;
  }

//Método leer
  Future<Map<String, dynamic>> read(String collection) async {
    Map<String, dynamic> dataResponse = {};
    List<dynamic> elements = [];
    if (await super.connected()) {
      try {
        final response = await ref.collection(collection).get();
        for (int i = 0; i < response.docs.length; i++) {
          switch (collection) {
            case "notes":
              elements.add(
                  Note.fromSnapshot(response.docs[i], response.docs[i].id));
              break;
            case "task":
              elements.add(task.Task.fromSnapshot(
                  response.docs[i], response.docs[i].id));
              break;
            default:
              break;
          }
        }
        dataResponse["data"] = elements;
        dataResponse["status"] = StatusNetwork.Connected;
      } catch (e) {
        dataResponse["status"] = StatusNetwork.Exception;
      }
    } else {
      dataResponse["status"] = StatusNetwork.NoInternet;
    }
    return dataResponse;
  }

//Método actualizar
  Future<Map<String, dynamic>> update(
      String collection, String id, Map<String, dynamic> data) async {
    Map<String, dynamic> dataResponse = {};
    if (await super.connected()) {
      try {
        await ref.collection(collection).doc(id).update(data);
        dataResponse["status"] = StatusNetwork.Connected;
      } catch (e) {
        dataResponse["status"] = StatusNetwork.Exception;
      }
    } else {
      dataResponse["status"] = StatusNetwork.NoInternet;
    }
    return dataResponse;
  }

//Método eliminar
  Future<Map<String, dynamic>> delete(String collection, String id) async {
    Map<String, dynamic> dataResponse = {};
    if (await super.connected()) {
      try {
        await ref.collection(collection).doc(id).delete();
        dataResponse["status"] = StatusNetwork.Connected;
      } catch (e) {
        dataResponse["status"] = StatusNetwork.Exception;
      }
    } else {
      dataResponse["status"] = StatusNetwork.NoInternet;
    }
    return dataResponse;
  }
}
