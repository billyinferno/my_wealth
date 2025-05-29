import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class FavouritesProvider extends ChangeNotifier {
  List<FavouritesModel>? favouriteListReksadana;
  List<FavouritesModel>? favouriteListSaham;
  List<FavouritesModel>? favouriteListCrypto;

  void setFavouriteList({
    required String type,
    required List<FavouritesModel> favouriteListData
  }) {
    if (type == "reksadana") {
      favouriteListReksadana = favouriteListData;
    }
    else if (type == "saham") {
      favouriteListSaham = favouriteListData;
    }
    else if (type == "crypto") {
      favouriteListCrypto = favouriteListData;
    }
    notifyListeners();
  }
}