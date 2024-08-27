import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class FavouritesAPI {
  Future<List<FavouritesModel>> getFavourites({required String type}) async {
    // get the favourites data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiFavourites}/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

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
    // get the favourites data using netutils
    final String body = await NetUtils.get(
      url: '${Globals.apiFavourites}/list/$type'
    ).onError((error, stackTrace) {
        throw Exception(error);
      }
    );

    // parse the response to get user favorit list
    CommonArrayModel commonModel = CommonArrayModel.fromJson(jsonDecode(body));
    List<FavouritesListModel> listFavourites = [];
    for (var data in commonModel.data) {
      // print(_data['attributes'].toString());
      FavouritesListModel fave = FavouritesListModel.fromJson(data['attributes']);
      listFavourites.add(fave);
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
        throw Exception(error);
      }
    );

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
        throw Exception(error);
      }
    );
    
    // no need to response the data returned by delete
    return;
  }
}