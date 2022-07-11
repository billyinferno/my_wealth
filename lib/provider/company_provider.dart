import 'package:flutter/material.dart';
import 'package:my_wealth/model/sector_name_list_model.dart';

class CompanyProvider extends ChangeNotifier {
  List<SectorNameModel>? sectorNameList;

  setSectorList(List<SectorNameModel> sectorListData) {
    sectorNameList = sectorListData;
    notifyListeners();
  }
}