import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class CompanyProvider extends ChangeNotifier {
  List<SectorNameModel>? sectorNameList;
  List<CompanySahamListModel>? companySahamList;

  setSectorList({
    required List<SectorNameModel> sectorListData
  }) {
    sectorNameList = sectorListData;
    notifyListeners();
  }

  setCompanySahamList({
    required List<CompanySahamListModel> companySahamListData
  }) {
    companySahamList = companySahamListData;
    notifyListeners();
  }
}