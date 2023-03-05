import 'package:flutter/material.dart';
import 'package:my_wealth/model/index/index_model.dart';

class IndexProvider extends ChangeNotifier {
  List<IndexModel>? indexList;

  setIndexList(List<IndexModel> indexListData) {
    indexList = indexListData;
    notifyListeners();
  }
}