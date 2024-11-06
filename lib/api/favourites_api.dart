import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class FavouritesAPI {
  Future<List<FavouritesModel>> getFavourites({required String type}) async {
    // get the favourites data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiFavourites}/$type'
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on getFavourites',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response to get user favourite list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<FavouritesModel> listFavourites = [];
    for (var data in commonModel.data) {
      FavouritesModel fave = FavouritesModel.fromJson(data['attributes']);
      listFavourites.add(fave);
    }
    return listFavourites;
  }

  Future<List<FavouritesListModel>> listFavouritesCompanies({
    required String type
  }) async {
    // get the list favourites from cache
    List<FavouritesListModel> listFavourites = FavouritesSharedPreferences.getFavouriteCompanyList(type: type);
    
    // check if favourites is empty or not?
    if (listFavourites.isEmpty) {
      // get the favourites data using netutils
      final String body = await NetUtils.get(
        url: '${Globals.apiFavourites}/list/$type'
      ).onError((error, stackTrace) {
        Log.error(
          message: 'Error on listFavouritesCompanies',
          error: error,
          stackTrace: stackTrace,
        );
        throw error as NetException;
      });

      // parse the response to get user favorit list
      CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
      for (var data in commonModel.data) {
        // print(_data['attributes'].toString());
        FavouritesListModel fave = FavouritesListModel.fromJson(data['attributes']);
        listFavourites.add(fave);
      }

      // save the favourites list to the local box for cache
      FavouritesSharedPreferences.setFavouriteCompanyList(
        type: type,
        list: listFavourites
      );
    }

    return listFavourites;
  }

  Future<FavouritesListModel> add({
    required int companyId,
    required String type,
  }) async {
    // post the favourites data using netutils
    final String body = await NetUtils.post(
      url: '${Globals.apiFavourites}/$type',
      body: {'favourites_company_id': companyId}
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on add',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });

    // parse the response from adding company as favourites
    CommonSingleModel commonModel = CommonSingleModel.fromJson(jsonDecode(body));
    FavouritesListModel userFave = FavouritesListModel.fromJson(commonModel.data['attributes']);
    return userFave;
  }

  Future<void> delete({required int favouriteId}) async {
    // delete the favourites data using netutils
    await NetUtils.delete(
      url: '${Globals.apiFavourites}/$favouriteId',
    ).onError((error, stackTrace) {
      Log.error(
        message: 'Error on delete',
        error: error,
        stackTrace: stackTrace,
      );
      throw error as NetException;
    });
    
    // no need to response the data returned by delete
    return;
  }
}