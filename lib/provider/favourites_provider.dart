import 'package:flutter/material.dart';
import 'package:my_wealth/model/favourites_model.dart';

class FavouritesProvider extends ChangeNotifier {
  List<FavouritesModel>? favouriteListReksadana;
  List<FavouritesModel>? favouriteListSaham;
  List<FavouritesModel>? favouriteListCrypto;

  setFavouriteList(String type, List<FavouritesModel> favouriteListData) {
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