import 'package:app_notas/src/core/constants/parameters.dart';
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
        ref.collection(collection).add(data);
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
  Future<Map<String, dynamic>> read(String s) async {
    Map<String, dynamic> dataResponse = {};
    if (await super.connected()) {
      try {
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
        ref.collection(collection).doc(id).update(data);
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
  Future<Map<String, dynamic>> delete() async {
    Map<String, dynamic> dataResponse = {};
    if (await super.connected()) {
      try {
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
