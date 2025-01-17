import 'package:hive/hive.dart';

class SaveOnLocalStorage {
  late dynamic mainBox;

  SaveOnLocalStorage(String boxName) {
    mainBox = Hive.box(boxName);
  }

  void writeDate(String key, value) async {
    try {
      await mainBox.put(key, value);
    } on Exception {
      throw Exception();
    }
  }

  Future<dynamic> getAllData() async {
    var dados = await mainBox.values.toList();
    return dados;
  }

  Future<Map> getData(key) async {
    var dados = await mainBox.get(key);
    if (dados == null)
      return {};
    else
      return dados;
  }

  Future<List> getRotas(key) async {
    var dados = await mainBox.get(key);
    if (dados == null) {
      return [];
    } else {
      return dados;
    }
  }

  void deleteData(key) async {
    try {
      await mainBox.delete(key);
    } on Exception {}
  }

  void addOnBox(data) async {
    await mainBox.put("rotas", data);
  }

  void writeRota(String key) {}
}
