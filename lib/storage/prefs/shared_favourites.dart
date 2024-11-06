import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class FavouritesSharedPreferences {
  static const _favouriteKey = "favourites_list";
  static const _favouriteCompanyListKey = "favourites_company_list_";

  static Future<void> setFavouritesList({
    required String type,
    required List<FavouritesModel> favouriteList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> favouriteListRet = [];
    for (FavouritesModel fave in favouriteList) {
      favouriteListRet.add(jsonEncode(fave.toJson()));
    }
    await LocalBox.putStringList(
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

  static Future<void> setFavouriteCompanyList({
    required String type,
    required List<FavouritesListModel> list,
  }) async {
    // convert all the FavouritesListModel to JSON string
    List<String> favouritesCompanyList = [];
    for (FavouritesListModel company in list) {
      favouritesCompanyList.add(jsonEncode(company.toJson()));
    }

    // store it on local box
    await LocalBox.putStringList(
      key: "$_favouriteCompanyListKey$type",
      value: favouritesCompanyList,
      cache: true,
    );
  }

  static List<FavouritesListModel> getFavouriteCompanyList({
    required String type,
  }) {
    // get the favourite company list from local box
    List<String> favouriteCompanyStringList = (
      LocalBox.getStringList(
        key: "$_favouriteCompanyListKey$type",
        cache: true,
      ) ?? []
    );

    // check if it's empty or not?
    if (favouriteCompanyStringList.isNotEmpty) {
      // convert favourite company list string into FavouritesListModel
      List<FavouritesListModel> favouriteCompanyList = [];
      for (String company in favouriteCompanyStringList) {
        favouriteCompanyList.add(FavouritesListModel.fromJson(jsonDecode(company)));
      }

      // return the data
      return favouriteCompanyList;
    }
    else {
      // return empty array
      return [];
    }
  }

  static Future<void> updateFavouriteCompanyList({
    required String type,
    required FavouritesListModel update,
  }) async {
    // get the favourite company list from local box
    List<String> favouriteCompanyStringList = (
      LocalBox.getStringList(
        key: "$_favouriteCompanyListKey$type",
        cache: true,
      ) ?? []
    );

    // check if it's empty or not?
    if (favouriteCompanyStringList.isNotEmpty) {
      // convert favourite company list string into FavouritesListModel
      List<FavouritesListModel> favouriteCompanyList = [];
      for (String company in favouriteCompanyStringList) {
        favouriteCompanyList.add(FavouritesListModel.fromJson(jsonDecode(company)));
      }

      // loop for favouriteCompanyList to update the data
      for(int i=0; i<favouriteCompanyList.length; i++) {
        // check if same company ID or not?
        // if same, then update the data
        if (favouriteCompanyList[i].favouritesCompanyId == update.favouritesCompanyId) {
          favouriteCompanyList[i] = update;
          break;
        }
      }

      // by right once we reach here the favouriteCompanyList should be already
      // updated with the latest data, so now we can replace the one we stored
      // in the local box
      await setFavouriteCompanyList(type: type, list: favouriteCompanyList);
    }
  }

  static Future<void> clearFavouriteCompanyList() async {
    // clear the favourite company list
    await LocalBox.delete(key: _favouriteCompanyListKey, cache: true);
  }
}