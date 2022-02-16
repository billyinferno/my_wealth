import 'package:flutter/material.dart';
import 'package:my_wealth/model/favourites_model.dart';

class FavouritesProvider extends ChangeNotifier {
  List<FavouritesModel>? favouriteList;

  setFavouriteList(List<FavouritesModel> favouriteListData) {
    favouriteList = favouriteListData;
    notifyListeners();
  }
}