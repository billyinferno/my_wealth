import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class IndexProvider extends ChangeNotifier {
  List<IndexModel>? indexList;

  void setIndexList({required List<IndexModel> indexListData}) {
    indexList = indexListData;
    notifyListeners();
  }
}