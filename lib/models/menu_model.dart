import 'package:fl_business/models/models.dart';

class MenuModel {
  MenuModel({
    required this.name,
    // required this.id,
    required this.route,
    required this.children,
    this.idChild,
    this.idFather,
    required this.display,
    required this.app,
  });

  String name;
  // int id;
  String route;
  int? idFather;
  int? idChild;
  int app;
  List<MenuModel> children;
  DisplayModel? display;
}

class MenuData {
  MenuData({required this.application, required this.children});

  ApplicationModel application;
  List<DisplayModel> children;
}
