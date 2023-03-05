import 'package:flutter/material.dart';
import 'package:my_wealth/model/company/company_saham_list_model.dart';
import 'package:my_wealth/model/insight/insight_sector_name_list_model.dart';

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