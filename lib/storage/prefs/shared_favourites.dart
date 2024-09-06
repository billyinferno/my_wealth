import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class FavouritesSharedPreferences {
  static const _favouriteKey = "favourites_list";

  static Future<void> setFavouritesList({
    required String type,
    required List<FavouritesModel> favouriteList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> favouriteListRet = [];
    for (FavouritesModel fave in favouriteList) {
      favouriteListRet.add(jsonEncode(fave.toJson()));
    }
    LocalBox.putStringList(
      key: "${_favouriteKey}_$type",
      value: favouriteListRet
    );
  }

  static List<FavouritesModel> getFavouritesList({required String type}) {
    // get the data from local box
    List<String> favouriteListString = (
      LocalBox.getStringList(key: "${_favouriteKey}_$type") ?? []
    );

    // check if the list is empty or not?
    if (favouriteListString.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<FavouritesModel> ret = [];
      for (String faveString in favouriteListString) {
        FavouritesModel fave = FavouritesModel.fromJson(jsonDecode(faveString));
        ret.add(fave);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }
}