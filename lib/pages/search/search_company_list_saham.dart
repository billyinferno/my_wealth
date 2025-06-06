import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class SearchCompanyListSahamPage extends StatefulWidget {
  const SearchCompanyListSahamPage({super.key});

  @override
  State<SearchCompanyListSahamPage> createState() => _SearchCompanyListSahamPageState();
}

class _SearchCompanyListSahamPageState extends State<SearchCompanyListSahamPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _filterMode;
  late SortBoxType _filterSort;
  final Map<String, String> _filterList = {};

  late CompanyLastUpdateModel _lastUpdate;

  late Future<bool> _getData;

  late bool _isShowDecomm;
  late bool _isShowFCA;

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterFaveList = [];
  List<FavouritesListModel> _sortedFaveList = [];

  @override
  void initState() {
    super.initState();

    // get the max last update
    _lastUpdate = CompanySharedPreferences.getCompanyLastUpdateModel(
      type: CompanyLastUpdateType.max,
    );

    // list all the filter that we want to put here
    _filterList["nm"] = "Name";
    _filterList["1d"] = "One Day";
    _filterList["1w"] = "One Week";
    _filterList["1m"] = "One Month";
    _filterList["3m"] = "Three Month";
    _filterList["6m"] = "Six Month";
    _filterList["yt"] = "Year To Date";
    _filterList["1y"] = "One Year";
    _filterList["fc"] = "Full Call Auction";

    // default filter mode to Code and ASC
    _filterMode = "nm";
    _filterSort = SortBoxType.ascending;

    // default the is show decom and fca to true
    _isShowDecomm = true;
    _isShowFCA = true;

    // get the favourite company list for saham
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
          return const CommonErrorPage(errorText: 'Error loading saham favourite list');
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
            "Search Stock",
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
            await _getUserFavourites().whenComplete(() {
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
            SortBox(
              initialFilter: _filterMode,
              filterList: _filterList,
              filterSort: _filterSort,
              onChanged: (filter, sort) {
                setState(() {
                  _filterMode = filter;
                  _filterSort = sort;
                  _sortedFave();
                });
              },
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CupertinoSearchTextField(
                controller: _textController,
                onChanged: ((value) {
                  if (value.length >= 3) {
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CupertinoSwitch(
                        value: _isShowDecomm,
                        onChanged: ((val) {
                          setState(() {  
                            _isShowDecomm = val;
                            _filterData();
                          });
                        }),
                        activeTrackColor: accentDark,
                      ),
                      const SizedBox(width: 5,),
                      const Text("Show Decomm"),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CupertinoSwitch(
                        value: _isShowFCA,
                        onChanged: ((val) {
                          setState(() {  
                            _isShowFCA = val;
                            _filterData();
                          });
                        }),
                        activeTrackColor: accentDark,
                      ),
                      const SizedBox(width: 5,),
                      const Text("Show FCA"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Showed ${_filterFaveList.length} company(s)",
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
                itemCount: _sortedFaveList.length,
                itemBuilder: ((context, index) {
                  bool isWarning = false;
                  // check for the company last update
                  if (_sortedFaveList[index].favouritesLastUpdate != null) {
                    if (_sortedFaveList[index].favouritesLastUpdate!.isBeforeDate(date: _lastUpdate.saham)) {
                      isWarning = true;
                    }
                  }

                  return InkWell(
                    onTap: (() {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: _sortedFaveList[index].favouritesCompanyId,
                        companyName: _sortedFaveList[index].favouritesCompanyName,
                        companyCode: _sortedFaveList[index].favouritesSymbol,
                        companyFavourite: ((_sortedFaveList[index].favouritesUserId ?? -1) > 0 ? true : false),
                        favouritesId: (_sortedFaveList[index].favouritesId ?? -1),
                        type: "saham",
                      );
          
                      Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
                    }),
                    child: FavouriteCompanyList(
                      companyId: _sortedFaveList[index].favouritesCompanyId,
                      name: "(${_sortedFaveList[index].favouritesSymbol}) ${_sortedFaveList[index].favouritesCompanyName}",
                      type: _sortedFaveList[index].favouritesCompanyType,
                      date: Globals.dfddMMyyyy.formatDateWithNull(_sortedFaveList[index].favouritesLastUpdate),
                      value: _sortedFaveList[index].favouritesNetAssetValue,
                      isFavourite: ((_sortedFaveList[index].favouritesUserId ?? -1) > 0 ? true : false),
                      fca: (_sortedFaveList[index].favouritesFCA ?? false),
                      warning: isWarning,
                      warningIcon: Ionicons.lock_closed,
                      subWidget: _subInfoWidget(_sortedFaveList[index]),
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

  Widget _subInfoWidget(FavouritesListModel data) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _infoWidget(
            header: "1d",
            value: data.favouritesCompanyDailyReturn,
          ),
          _infoWidget(
            header: "1w",
            value: data.favouritesCompanyWeeklyReturn,
          ),
          _infoWidget(
            header: "1m",
            value: data.favouritesCompanyMonthlyReturn,
          ),
          _infoWidget(
            header: "3m",
            value: data.favouritesCompanyQuarterlyReturn,
          ),
          _infoWidget(
            header: "6m",
            value: data.favouritesCompanySemiAnnualReturn,
          ),
          _infoWidget(
            header: "ytd",
            value: data.favouritesCompanyYTDReturn,
          ),
          _infoWidget(
            header: "1y",
            value: data.favouritesCompanyYearlyReturn,
          ),
        ],
      ),
    );
  }

  Widget _infoWidget({required String header, double? value}) {
    Color valueColor = textPrimary;
    if (value != null) {
      if (value < 0) {
        valueColor = secondaryColor;
      }
      if (value > 0) {
        valueColor = Colors.green;
      }
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            header,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${formatDecimalWithNull(
              value,
              times: 100,
              decimal: 2
            )}%",
            style: TextStyle(
              fontSize: 10,
              color: valueColor
            ),
          ),
        ],
      ),
    );
  }

  void _sortedFave() {
    // clear the current code list as we will rebuild t his
    _sortedFaveList.clear();

    // if the filter mode is "nm" which is name, then just copy from the _filterFaveList
    if (_filterMode == "nm") {
      // check the sort methode?
      if (_filterSort == SortBoxType.ascending) {
        _sortedFaveList = List<FavouritesListModel>.from(_filterFaveList);
      }
      else {
        _sortedFaveList = List<FavouritesListModel>.from(_filterFaveList.reversed);
      }
    }
    else if (_filterMode == "fc") {
      _sortedFaveList.clear();
      for(int i=0; i<_filterFaveList.length; i++) {
        if(_filterFaveList[i].favouritesFCA ?? false) {
          _sortedFaveList.add(_filterFaveList[i]);
        }
      }

      // check if ascending or descending
      if (_filterSort != SortBoxType.ascending) {
        _sortedFaveList = List<FavouritesListModel>.from(_sortedFaveList.reversed);
      }
    }
    else {
      List<FavouritesListModel> tempFilter = List<FavouritesListModel>.from(_filterFaveList);
      switch(_filterMode) {
        case "1d":
          tempFilter.sort(((a, b) => (a.favouritesCompanyDailyReturn ?? 0).compareTo((b.favouritesCompanyDailyReturn ?? 0))));
          break;
        case "1w":
          tempFilter.sort(((a, b) => (a.favouritesCompanyWeeklyReturn ?? 0).compareTo((b.favouritesCompanyWeeklyReturn ?? 0))));
          break;
        case "1m":
          tempFilter.sort(((a, b) => (a.favouritesCompanyMonthlyReturn ?? 0).compareTo((b.favouritesCompanyMonthlyReturn ?? 0))));
          break;
        case "3m":
          tempFilter.sort(((a, b) => (a.favouritesCompanyQuarterlyReturn ?? 0).compareTo((b.favouritesCompanyQuarterlyReturn ?? 0))));
          break;
        case "6m":
          tempFilter.sort(((a, b) => (a.favouritesCompanySemiAnnualReturn ?? 0).compareTo((b.favouritesCompanySemiAnnualReturn ?? 0))));
          break;
        case "yt":
          tempFilter.sort(((a, b) => (a.favouritesCompanyYTDReturn ?? 0).compareTo((b.favouritesCompanyYTDReturn ?? 0))));
          break;
        case "1y":
          tempFilter.sort(((a, b) => (a.favouritesCompanyYearlyReturn ?? 0).compareTo((b.favouritesCompanyYearlyReturn ?? 0))));
          break;
        default:
          tempFilter.sort(((a, b) => (a.favouritesCompanyDailyReturn ?? 0).compareTo((b.favouritesCompanyDailyReturn ?? 0))));
          break;
      }

      // check the filter type
      if (_filterSort == SortBoxType.ascending) {
        _sortedFaveList = List<FavouritesListModel>.from(tempFilter);
      }
      else {
        _sortedFaveList = List<FavouritesListModel>.from(tempFilter.reversed);
      }
    }
  }

  void _searchList(String find) {
    // clear the filter list first
    _filterFaveList.clear();
    // then loop thru _faveList and check if the company name or code contain the text we want to find
    for (var i = 0; i < _faveList.length; i++) {
      if (_faveList[i].favouritesCompanyName.toLowerCase().contains(find.toLowerCase()) || _faveList[i].favouritesSymbol.toLowerCase().contains(find.toLowerCase())) {
        // add this filter list
        _filterFaveList.add(_faveList[i]);
      }
    }
    _sortedFave();
  }

  void _filterData() {
    // clear the filter list first
    _filterFaveList.clear();

    // then loop thru _faveList and check whether we want to show fca and
    // decommisionned company or not?
    bool isAdd;  
    for (var i = 0; i < _faveList.length; i++) {
      // default isAdd to true
      isAdd = true;

      // check if we want to show fca or not?
      if (!_isShowFCA) {
        // check if the current company is fca or not?
        if ((_faveList[i].favouritesFCA ?? false)) {
          // no need to add this company
          isAdd = false;
        }
      }

      // check if need to add or not?
      if (isAdd) {
        // check if the current company is decommissioned or not?
        if (!_isShowDecomm) {
          // check the company last update is the same as the last update from
          // server or not?
          if (_faveList[i].favouritesLastUpdate!.isBeforeDate(date: _lastUpdate.saham)) {
            isAdd = false;
          }
        }
      }
      
      // check if we need to add this or not?
      if (isAdd) {
        // add this filter list
        _filterFaveList.add(_faveList[i]);
      }
    }

    // once finished sorted the fave list
    _sortedFave();
  }

  void _updateFaveList(int index, FavouritesListModel resp) {
    setState(() {
      _sortedFaveList[index] = resp;
      for (var i = 0; i < _faveList.length; i++) {
        if (_faveList[i].favouritesCompanyId == _sortedFaveList[index].favouritesCompanyId) {
          // update this fave list
          _faveList[i] = resp;
          return;
        }
      }
      for (var i = 0; i < _filterFaveList.length; i++) {
        if (_filterFaveList[i].favouritesCompanyId == _sortedFaveList[index].favouritesCompanyId) {
          // update this fave list
          _filterFaveList[i] = resp;
          return;
        }
      }
    });
  }

  Future<void> _setFavourite(int index) async {
    // check if this is already favourite or not?
    int faveUserId = _sortedFaveList[index].favouritesUserId ?? -1;
    int faveId = _sortedFaveList[index].favouritesId ?? -1;
    if (faveUserId > 0 && faveId > 0) {
      // already favourite, delete the favourite
      await _faveAPI.delete(favouriteId: faveId).then((_) {
        Log.success(message: "🧹 Delete Favourite ID $faveId for stock company ${_sortedFaveList[index].favouritesCompanyName}");
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel resp = FavouritesListModel(
          favouritesCompanyId: _sortedFaveList[index].favouritesCompanyId,
          favouritesCompanyName: _sortedFaveList[index].favouritesCompanyName,
          favouritesSymbol: _sortedFaveList[index].favouritesSymbol,
          favouritesCompanyType: _sortedFaveList[index].favouritesCompanyType,
          favouritesNetAssetValue: _sortedFaveList[index].favouritesNetAssetValue,
          favouritesCompanyDailyReturn: _sortedFaveList[index].favouritesCompanyDailyReturn,
          favouritesCompanyWeeklyReturn: _sortedFaveList[index].favouritesCompanyWeeklyReturn,
          favouritesCompanyMonthlyReturn: _sortedFaveList[index].favouritesCompanyMonthlyReturn,
          favouritesCompanyQuarterlyReturn: _sortedFaveList[index].favouritesCompanyQuarterlyReturn,
          favouritesCompanySemiAnnualReturn: _sortedFaveList[index].favouritesCompanySemiAnnualReturn,
          favouritesCompanyYTDReturn: _sortedFaveList[index].favouritesCompanyYTDReturn,
          favouritesCompanyYearlyReturn: _sortedFaveList[index].favouritesCompanyYearlyReturn,
          favouritesLastUpdate: _sortedFaveList[index].favouritesLastUpdate,
          favouritesId: -1,
          favouritesUserId: -1,
        );

        // stored update favourites company in the cache 
        FavouritesSharedPreferences.updateFavouriteCompanyList(
          type: "saham",
          update: resp
        );

        // update the list and re-render the page
        _updateFaveList(index, resp);
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error delete favourites',
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
        companyId: _sortedFaveList[index].favouritesCompanyId,
        type: "saham",
      ).then((resp) {
        Log.success(message: "➕ Add stock company ID: ${_sortedFaveList[index].favouritesCompanyId} for company ${_sortedFaveList[index].favouritesCompanyName}");
        // update the list with the updated response and re-render the page
        FavouritesListModel ret = FavouritesListModel(
          favouritesCompanyId: _sortedFaveList[index].favouritesCompanyId,
          favouritesCompanyName: _sortedFaveList[index].favouritesCompanyName,
          favouritesSymbol: _sortedFaveList[index].favouritesSymbol,
          favouritesCompanyType: _sortedFaveList[index].favouritesCompanyType,
          favouritesNetAssetValue: _sortedFaveList[index].favouritesNetAssetValue,
          favouritesCompanyDailyReturn: _sortedFaveList[index].favouritesCompanyDailyReturn,
          favouritesCompanyWeeklyReturn: _sortedFaveList[index].favouritesCompanyWeeklyReturn,
          favouritesCompanyMonthlyReturn: _sortedFaveList[index].favouritesCompanyMonthlyReturn,
          favouritesCompanyQuarterlyReturn: _sortedFaveList[index].favouritesCompanyQuarterlyReturn,
          favouritesCompanySemiAnnualReturn: _sortedFaveList[index].favouritesCompanySemiAnnualReturn,
          favouritesCompanyYTDReturn: _sortedFaveList[index].favouritesCompanyYTDReturn,
          favouritesCompanyYearlyReturn: _sortedFaveList[index].favouritesCompanyYearlyReturn,
          favouritesLastUpdate: resp.favouritesLastUpdate,
          favouritesId: resp.favouritesId,
          favouritesUserId: resp.favouritesUserId,
        );

        // stored update favourites company in the cache 
        FavouritesSharedPreferences.updateFavouriteCompanyList(
          type: "saham",
          update: ret
        );

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
      _filterFaveList = List<FavouritesListModel>.from(list);
      _sortedFave();
    });
  }

  Future<void> _getUserFavourites() async {
    // show the loading screen
    LoadingScreen.instance().show(context: context);

    // get the favourites so we can showed it on the favourites page
    await _faveAPI.getFavourites(type: "saham").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList(
        type: "saham",
        favouriteList: resp,
      );

      // notify the provider
      if (!mounted) return;
      Provider.of<FavouritesProvider>(
        context,
        listen: false
      ).setFavouriteList(
        type: "saham",
        favouriteListData: resp,
      );
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error when get user favourites',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception('Error when get user favourites');
    },);

    // hide loading screen
    LoadingScreen.instance().hide();
  }

  Future<bool> _getInitData() async {
    await _faveAPI.listFavouritesCompanies(type: "saham").then((resp) {
      _setFavouriteList(resp);
      _setFilterList(resp);
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting saham list',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get saham list');
    },);

    return true;
  }
}