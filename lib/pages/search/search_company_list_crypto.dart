import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final DateFormat _dt = DateFormat("dd/MM/yyyy");

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
    super.dispose();
    // dispose all the controller
    _textController.dispose();
    _scrollController.dispose();
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
            await getUserFavourites().onError((error, stackTrace) {
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
                      searchList(value);
                    });
                  }
                  else {
                    // if less than 3, then we will return the value of filter list
                    // with all the fave list.
                    setFilterList(_faveList);
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
                      date: formatDateWithNulll(date: _filterList[index].favouritesLastUpdate, format: _dt),
                      value: _filterList[index].favouritesNetAssetValue,
                      isFavourite: ((_filterList[index].favouritesUserId ?? -1) > 0 ? true : false),
                      fca: (_filterList[index].favouritesFCA ?? false),
                      onPress: (() async {
                        await setFavourite(index);
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

  void searchList(String find) {
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

  void updateFaveList(int index, FavouritesListModel resp) {
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

  Future<void> setFavourite(int index) async {
    // check if this is already favourite or not?
    int faveUserId = _filterList[index].favouritesUserId ?? -1;
    int faveId = _filterList[index].favouritesId ?? -1;
    if (faveUserId > 0 && faveId > 0) {
      // already favourite, delete the favourite
      await _faveAPI.delete(faveId).then((_) {
        Log.success(message: "🧹 Delete Favourite ID $faveId for Crypto company ${_filterList[index].favouritesCompanyName}");
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel resp = FavouritesListModel(
          favouritesCompanyId: _filterList[index].favouritesCompanyId,
          favouritesCompanyName: _filterList[index].favouritesCompanyName,
          favouritesSymbol: _filterList[index].favouritesSymbol,
          favouritesCompanyType: _filterList[index].favouritesCompanyType,
          favouritesNetAssetValue: _filterList[index].favouritesNetAssetValue,
          favouritesLastUpdate: _filterList[index].favouritesLastUpdate
        );

        // update the list and re-render the page
        updateFaveList(index, resp);
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
      await _faveAPI.add(_filterList[index].favouritesCompanyId, "crypto").then((resp) {
        Log.success(message: "➕ Add Crypto company ID: ${_filterList[index].favouritesCompanyId} for company ${_filterList[index].favouritesCompanyName}");
        // update the list with the updated response and re-render the page
        updateFaveList(index, resp);
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

  void setFavouriteList(List<FavouritesListModel> list) {
    setState(() {
      _faveList = List<FavouritesListModel>.from(list);
    });
  }

  void setFilterList(List<FavouritesListModel> list) {
    setState(() {
      _filterList = List<FavouritesListModel>.from(list);
    });
  }

  Future<void> getFavouriteCompanyList() async {
    await _faveAPI.listFavouritesCompanies("crypto").then((resp) {
      setFavouriteList(resp);
      setFilterList(resp);
    });
  }

  Future<void> getUserFavourites() async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // get the favourites list
    await _faveAPI.getFavourites("crypto").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList("crypto", resp);
      // notify the provider
      if (!mounted) return;
      Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("crypto", resp);
    });

    // remove the loading screen
    LoadingScreen.instance().hide();
  }

  Future<bool> _getInitData() async {
    await getFavouriteCompanyList().onError((error, stackTrace) {
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