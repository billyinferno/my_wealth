import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class SearchCompanyListCryptoPage extends StatefulWidget {
  const SearchCompanyListCryptoPage({super.key});

  @override
  State<SearchCompanyListCryptoPage> createState() => _SearchCompanyListCryptoPageState();
}

class _SearchCompanyListCryptoPageState extends State<SearchCompanyListCryptoPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late Future<bool> _getData;

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterList = [];

  @override
  void initState() {
    super.initState();

    _getData = _getInitData();
  }

  @override
  void dispose() {
    // dispose all the controller
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading crypto company list');
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage();
        }
      },
    );
  }

  Widget _body() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Search Crypto",
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (() async {
            // fetch the user favorites when we return back to the favorites screen
            // and notify the provider to we can update the favorites screen based
            // on the new favorites being add/remove from this page
            await _getUserFavourites().onError((error, stackTrace) {
              // in case error showed it on debug
              Log.error(
                message: 'Error getting user favourites',
                error: error,
                stackTrace: stackTrace,
              );
        
              // print on the scaffold snack bar
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when retrieve user favourites'));
              }
            }).whenComplete(() {
              if (mounted) {
                // return back to the previous page
                Navigator.pop(context);
              }
            });
          }),
        ),
      ),
      body: MySafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CupertinoSearchTextField(
                controller: _textController,
                onChanged: ((value) {
                  // for crypto we can search when it matched "2", as the code usually will be at least "3"
                  if (value.length >= 2) {
                    setState(() {
                      _searchList(value);
                    });
                  }
                  else {
                    // if less than 3, then we will return the value of filter list
                    // with all the fave list.
                    _setFilterList(_faveList);
                  }
                }),
                suffixMode: OverlayVisibilityMode.editing,
                style: const TextStyle(
                  color: textPrimary,
                  fontFamily: '--apple-system'
                ),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Showed ${_filterList.length} company(s)",
                style: const TextStyle(
                  color: primaryLight,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filterList.length,
                itemBuilder: ((context, index) {
                  return InkWell(
                    onTap: (() {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: _filterList[index].favouritesCompanyId,
                        companyName: _filterList[index].favouritesCompanyName,
                        companyCode: _filterList[index].favouritesSymbol,
                        companyFavourite: ((_filterList[index].favouritesUserId ?? -1) > 0 ? true : false),
                        favouritesId: (_filterList[index].favouritesId ?? -1),
                        type: "crypto",
                      );
          
                      Navigator.pushNamed(context, '/company/detail/crypto', arguments: args);
                    }),
                    child: FavouriteCompanyList(
                      companyId: _filterList[index].favouritesCompanyId,
                      name: "(${_filterList[index].favouritesSymbol}) ${_filterList[index].favouritesCompanyName}",
                      type: _filterList[index].favouritesCompanyType,
                      date: Globals.dfddMMyyyy.formatDateWithNull(_filterList[index].favouritesLastUpdate),
                      value: _filterList[index].favouritesNetAssetValue,
                      isFavourite: ((_filterList[index].favouritesUserId ?? -1) > 0 ? true : false),
                      fca: (_filterList[index].favouritesFCA ?? false),
                      onPress: (() async {
                        await _setFavourite(index);
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchList(String find) {
    // clear the filter list first
    _filterList.clear();
    // then loop thru _faveList and check if the company name and symbol contain the text we want to find
    for (var i = 0; i < _faveList.length; i++) {
      if (_faveList[i].favouritesCompanyName.toLowerCase().contains(find.toLowerCase()) || _faveList[i].favouritesSymbol.toLowerCase().contains(find.toLowerCase())) {
        // add this filter list
        _filterList.add(_faveList[i]);
      }
    }
  }

  void _updateFaveList(int index, FavouritesListModel resp) {
    setState(() {
      _filterList[index] = resp;
      for (var i = 0; i < _faveList.length; i++) {
        if (_faveList[i].favouritesCompanyId == _filterList[index].favouritesCompanyId) {
          // update this fave list
          _faveList[i] = resp;
          return;
        }
      }
    });
  }

  Future<void> _setFavourite(int index) async {
    // check if this is already favourite or not?
    int faveUserId = _filterList[index].favouritesUserId ?? -1;
    int faveId = _filterList[index].favouritesId ?? -1;
    if (faveUserId > 0 && faveId > 0) {
      // already favourite, delete the favourite
      await _faveAPI.delete(favouriteId: faveId).then((_) {
        Log.success(message: "🧹 Delete Favourite ID $faveId for Crypto company ${_filterList[index].favouritesCompanyName}");
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel resp = FavouritesListModel(
          favouritesCompanyId: _filterList[index].favouritesCompanyId,
          favouritesCompanyName: _filterList[index].favouritesCompanyName,
          favouritesSymbol: _filterList[index].favouritesSymbol,
          favouritesCompanyType: _filterList[index].favouritesCompanyType,
          favouritesNetAssetValue: _filterList[index].favouritesNetAssetValue,
          favouritesLastUpdate: _filterList[index].favouritesLastUpdate,
          favouritesId: -1,
          favouritesUserId: -1,
        );

        // stored update favourites company in the cache 
        FavouritesSharedPreferences.updateFavouriteCompanyList(
          type: "crypto",
          update: resp
        );

        // update the list and re-render the page
        _updateFaveList(index, resp);
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error deleting favourites',
          error: error,
          stackTrace: stackTrace,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to delete favourites"));
        }
      });
    }
    else {
      await _faveAPI.add(
        companyId: _filterList[index].favouritesCompanyId,
        type: "crypto",
      ).then((resp) {
        Log.success(message: "➕ Add Crypto company ID: ${_filterList[index].favouritesCompanyId} for company ${_filterList[index].favouritesCompanyName}");
        
        // create the favourite list model that we want to use to replace the
        // favourite list
        FavouritesListModel ret = FavouritesListModel(
          favouritesCompanyId: _filterList[index].favouritesCompanyId,
          favouritesCompanyName: _filterList[index].favouritesCompanyName,
          favouritesSymbol: _filterList[index].favouritesSymbol,
          favouritesCompanyType: _filterList[index].favouritesCompanyType,
          favouritesNetAssetValue: _filterList[index].favouritesNetAssetValue,
          favouritesLastUpdate: _filterList[index].favouritesLastUpdate,
          favouritesId: resp.favouritesId,
          favouritesUserId: resp.favouritesUserId,
        );

        // stored update favourites company in the cache 
        FavouritesSharedPreferences.updateFavouriteCompanyList(
          type: "crypto",
          update: ret
        );

        // update the list with the updated response and re-render the page
        _updateFaveList(index, ret);
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error adding favourites',
          error: error,
          stackTrace: stackTrace,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to add favourites"));
        }
      });
    }
  }

  void _setFavouriteList(List<FavouritesListModel> list) {
    setState(() {
      _faveList = List<FavouritesListModel>.from(list);
    });
  }

  void _setFilterList(List<FavouritesListModel> list) {
    setState(() {
      _filterList = List<FavouritesListModel>.from(list);
    });
  }

  Future<void> _getUserFavourites() async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // get the favourites list
    await _faveAPI.getFavourites(type: "crypto").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList(
        type: "crypto",
        favouriteList: resp
      );

      // notify the provider
      if (!mounted) return;
      Provider.of<FavouritesProvider>(
        context,
        listen: false
      ).setFavouriteList(
        type: "crypto",
        favouriteListData: resp,
      );
    });

    // remove the loading screen
    LoadingScreen.instance().hide();
  }

  Future<bool> _getInitData() async {
    await _faveAPI.listFavouritesCompanies(type: "crypto").then((resp) {
      _setFavouriteList(resp);
      _setFilterList(resp);
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting crypto company list',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when get crypto company list');
    });

    // return true to the caller
    return true;
  }
}