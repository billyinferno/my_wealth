import 'package:flutter/material.dart';
import 'package:my_wealth/model/company_saham_list_model.dart';
import 'package:my_wealth/model/sector_name_list_model.dart';

class CompanyProvider extends ChangeNotifier {
  List<SectorNameModel>? sectorNameList;
  List<CompanySahamListModel>? companySahamList;

  setSectorList(List<SectorNameModel> sectorListData) {
    sectorNameList = sectorListData;
    notifyListeners();
  }

  setCompanySahamList(List<CompanySahamListModel> companySahamListData) {
    companySahamList = companySahamListData;
    notifyListeners();
  }
}