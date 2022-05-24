import 'dart:convert';
import 'package:my_wealth/model/favourites_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class FavouritesSharedPreferences {
  static const _favouriteKey = "favourites_list";

  static Future<void> setFavouritesList(String type, List<FavouritesModel> favouriteList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> _favouriteList = [];
    for (FavouritesModel _fave in favouriteList) {
      _favouriteList.add(jsonEncode(_fave.toJson()));
    }
    LocalBox.putStringList(_favouriteKey + "_" + type, _favouriteList);
  }

  static List<FavouritesModel> getFavouritesList(String type) {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> _favouriteList = (LocalBox.getStringList(_favouriteKey + "_" + type) ?? []);

    // check if the list is empty or not?
    if (_favouriteList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<FavouritesModel> _ret = [];
      for (String _faveString in _favouriteList) {
        FavouritesModel _fave = FavouritesModel.fromJson(jsonDecode(_faveString));
        _ret.add(_fave);
      }

      // return the favourites list
      return _ret;
    }
    else {
      // no data
      return [];
    }
  }
}