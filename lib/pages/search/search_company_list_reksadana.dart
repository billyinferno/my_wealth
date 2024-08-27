import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class SearchCompanyListReksadanaPage extends StatefulWidget {
  const SearchCompanyListReksadanaPage({ super.key });

  @override
  SearchCompanyListReksadanaPageState createState() => SearchCompanyListReksadanaPageState();
}

class SearchCompanyListReksadanaPageState extends State<SearchCompanyListReksadanaPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dt = DateFormat("dd/MM/yyyy");
  final TextEditingController _textController = TextEditingController();
  final StepperSelectorController _stepperControllerRating = StepperSelectorController();
  final StepperSelectorController _stepperControllerRisk = StepperSelectorController();

  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};

  late Future<bool> _getData;

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterFaveList = [];
  List<FavouritesListModel> _sortedFaveList = [];
  bool _isCampuran = true;
  bool _isSaham = true;
  bool _isPasarUang = true;
  bool _isPendapatanTetap = true;
  bool _isShowAll = true;
  int _currentRatingNum = 0;
  int _currentRiskNum = 0;

  @override
  void initState() {
    super.initState();

    // list all the filter that we want to put here
    _filterList["nm"] = "Name";
    _filterList["1d"] = "One Day";
    _filterList["1w"] = "One Week";
    _filterList["1m"] = "One Month";
    _filterList["3m"] = "Three Month";
    _filterList["6m"] = "Six Month";
    _filterList["yt"] = "Year To Date";
    _filterList["1y"] = "One Year";
    _filterList["rt"] = "Rating";
    _filterList["rs"] = "Risk";

    // default filter mode to Code and ASC
    _filterMode = "nm";
    _filterSort = "ASC";

    // get the favourite company list for reksadana
    _getData = _getInitData();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _stepperControllerRisk.dispose();
    _stepperControllerRating.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading reksadana favourite list');
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
            "Search Mutual Fund",
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
            await _getUserFavourites().then((_) {
            }).onError((error, stackTrace) {
              // in case error showed it on debug
              Log.error(
                message: 'Error getting user favourites',
                error: error,
                stackTrace: stackTrace,
              );
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
            SearchBox(
              filterMode: _filterMode,
              filterList: _filterList,
              filterSort: _filterSort, 
              onFilterSelect: ((value) {
                setState(() {
                  _filterMode = value;
                  _sortedFave();
                });
              }),
              onSortSelect: ((value) {
                setState(() {
                  _filterSort = value;
                  _sortedFave();
                });
              })
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CupertinoSearchTextField(
                controller: _textController,
                onChanged: ((value) {
                  filterData();
                }),
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
              height: 175,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Type",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1,
                                    child: CupertinoSwitch(
                                      value: _isCampuran,
                                      onChanged: ((val) {
                                        _isCampuran = val;
                                        filterData();
                                      }),
                                      activeTrackColor: accentDark,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Text("Campuran"),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1,
                                    child: CupertinoSwitch(
                                      value: _isSaham,
                                      onChanged: ((val) {
                                        _isSaham = val;
                                        filterData();
                                      }),
                                      activeTrackColor: accentDark,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Text("Saham"),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1,
                                    child: CupertinoSwitch(
                                      value: _isPasarUang,
                                      onChanged: ((val) {
                                        _isPasarUang = val;
                                        filterData();
                                      }),
                                      activeTrackColor: accentDark,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Text("Pasar Uang"),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1,
                                    child: CupertinoSwitch(
                                      value: _isPendapatanTetap,
                                      onChanged: ((val) {
                                        _isPendapatanTetap = val;
                                        filterData();
                                      }),
                                      activeTrackColor: accentDark,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Text("Pend. Tetap"),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                "Rating",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                ),
                              ),
                              StepperSelector(
                                controller: _stepperControllerRating,
                                icon: Ionicons.star,
                                iconColor: accentColor,
                                defaultValue: _currentRatingNum,
                                onChanged: ((val) {
                                  _currentRatingNum = val;
                                  filterData();
                                }),
                              ),
                              const SizedBox(height: 10,),
                              const Text(
                                "Risk",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                ),
                              ),
                              StepperSelector(
                                controller: _stepperControllerRisk,
                                icon: Ionicons.alert,
                                iconColor: secondaryColor,
                                defaultValue: _currentRiskNum,
                                onChanged: ((val) {
                                  _currentRiskNum = val;
                                  filterData();
                                }),
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 1,
                                    child: CupertinoSwitch(
                                      value: _isShowAll,
                                      onChanged: ((val) {
                                        _isShowAll = val;
                                        filterData();
                                      }),
                                      activeTrackColor: accentDark,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  const Text("Show All"),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
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
                  return InkWell(
                    onTap: (() {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: _sortedFaveList[index].favouritesCompanyId,
                        companyName: _sortedFaveList[index].favouritesCompanyName,
                        companyCode: _sortedFaveList[index].favouritesSymbol,
                        companyFavourite: ((_sortedFaveList[index].favouritesUserId ?? -1) > 0 ? true : false),
                        favouritesId: (_sortedFaveList[index].favouritesId ?? -1),
                        type: "reksadana",
                      );
          
                      Navigator.pushNamed(context, '/company/detail/reksadana', arguments: args);
                    }),
                    child: FavouriteCompanyList(
                      companyId: _sortedFaveList[index].favouritesCompanyId,
                      name: _sortedFaveList[index].favouritesCompanyName,
                      type: Globals.reksadanaCompanyTypeEnum[_sortedFaveList[index].favouritesCompanyType]!,
                      date: formatDateWithNulll(date: _sortedFaveList[index].favouritesLastUpdate, format: _dt),
                      value: _sortedFaveList[index].favouritesNetAssetValue,
                      isFavourite: ((_sortedFaveList[index].favouritesUserId ?? -1) > 0 ? true : false),
                      fca: (_sortedFaveList[index].favouritesFCA ?? false),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _ratingRiskWidget(
                header: "Rating",
                value: data.favouritesCompanyYearlyRating,
                iconData: Ionicons.star,
                iconColor: Colors.yellow,
              ),
              _ratingRiskWidget(
                header: "Risk",
                value: data.favouritesCompanyYearlyRating,
                iconData: Ionicons.alert,
                iconColor: secondaryColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
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
        ),
      ],
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
            "${formatDecimalWithNull(value, 100, 2)}%",
            style: TextStyle(
              fontSize: 10,
              color: valueColor
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRiskWidget({required String header, double? value, required IconData iconData, required Color iconColor}) {
    int numRating = 0;
    if (value != null) {
      numRating = value.toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 50,
          child: Text(
            header,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: _generateRatingIcon(
              numRating: numRating,
              iconData: iconData,
              iconColor: iconColor
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _generateRatingIcon({required int numRating, required IconData iconData, required Color iconColor}) {
    if (numRating <= 0) {
      return List<Widget>.generate(1, (index) {
        return const Icon(
          Ionicons.remove,
          color: textPrimary,
          size: 10,
        );
      });
    }

    return List<Widget>.generate(numRating, (index) {
      return Icon(
        iconData,
        color: iconColor,
        size: 10,
      );
    });
  }

  void filterData() {
    // create a temporary list to hold resulted filter list
    List<FavouritesListModel> result = [];
    String find = _textController.text;
    bool isAdd = false;

    // first let's filter all the type needed
    for (FavouritesListModel fave in _faveList) {
      if (_isCampuran && _isPendapatanTetap && _isPasarUang && _isSaham) {
        // check whether we want to show all or not?
        if (_isShowAll) {
          result.add(fave);
        }
        else {
          if (fave.favouritesId! < 0) {
            result.add(fave);
          }
        }
      }
      else {
        // check the type first
        isAdd = false;
        if(fave.favouritesCompanyType == "reksadanacampuran" && _isCampuran) {
          isAdd = true;
        }
        if(fave.favouritesCompanyType == "reksadanapendapatantetap" && _isPendapatanTetap) {
          isAdd = true;
        }
        if(fave.favouritesCompanyType == "reksadanapasaruang" && _isPasarUang) {
          isAdd = true;
        }
        if(fave.favouritesCompanyType == "reksadanasaham" && _isSaham) {
          isAdd = true;
        }

        if (isAdd) {
          if (_isShowAll) {
            result.add(fave);
          }
          else {
            if (fave.favouritesId! < 0) {
              result.add(fave);
            }
          }
        }
      }
    }

    // create a temporary list for moving the data
    List<FavouritesListModel> temp = [];

    // now by right _result should be filled, we can now filter this based on the rating given
    if(_stepperControllerRating.value! > 0) {
      // duplicate the result
      temp.clear();
      temp = List<FavouritesListModel>.from(result);
      result.clear();

      for (FavouritesListModel fave in temp) {
        if (fave.favouritesCompanyYearlyRating!.toInt() >= _stepperControllerRating.value!) {
          result.add(fave);
        }
      }
    }

    // now by right _result should be filled, we can now filter this based on the rating given
    if(_stepperControllerRisk.value! > 0) {
      // duplicate the result
      temp.clear();
      temp = List<FavouritesListModel>.from(result);
      result.clear();

      for (FavouritesListModel fave in temp) {
        if (fave.favouritesCompanyYearlyRisk!.toInt() >= _stepperControllerRisk.value!) {
          result.add(fave);
        }
      }
    }

    // now check if the find text is more than 3 or not?
    if (find.length >= 3) {
      // check if the name contain the text in find or not?
      // duplicate the result
      temp.clear();
      temp = List<FavouritesListModel>.from(result);
      result.clear();

      for (FavouritesListModel fave in temp) {
        if(fave.favouritesCompanyName.toLowerCase().contains(find.toLowerCase())) {
          result.add(fave);
        }
      }
    }

    // once finished, set the _filterList with result
    _setFilterList(result);
  }

  void _sortedFave() {
    // clear the current code list as we will rebuild t his
    _sortedFaveList.clear();

    // if the filter mode is "nm" which is name, then just copy from the _filterFaveList
    if (_filterMode == "nm") {
      // check the sort methode?
      if (_filterSort == "ASC") {
        _sortedFaveList = List<FavouritesListModel>.from(_filterFaveList);
      }
      else {
        _sortedFaveList = List<FavouritesListModel>.from(_filterFaveList.reversed);
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
        case "rt":
          tempFilter.sort(((a, b) => (a.favouritesCompanyYearlyRating ?? -1).compareTo((b.favouritesCompanyYearlyRating ?? -1))));
          break;
        case "rs":
          tempFilter.sort(((a, b) => (a.favouritesCompanyYearlyRisk ?? 99).compareTo((b.favouritesCompanyYearlyRisk ?? 99))));
          break;
        default:
          tempFilter.sort(((a, b) => (a.favouritesCompanyDailyReturn ?? 0).compareTo((b.favouritesCompanyDailyReturn ?? 0))));
          break;
      }

      // check the filter type
      if (_filterSort == "ASC") {
        _sortedFaveList = List<FavouritesListModel>.from(tempFilter);
      }
      else {
        _sortedFaveList = List<FavouritesListModel>.from(tempFilter.reversed);
      }
    }
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
        Log.success(message: "🧹 Delete Favourite ID $faveId for reksadana company ${_sortedFaveList[index].favouritesCompanyName}");
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel resp = FavouritesListModel(
          favouritesCompanyId: _sortedFaveList[index].favouritesCompanyId,
          favouritesCompanyName: _sortedFaveList[index].favouritesCompanyName,
          favouritesSymbol: _sortedFaveList[index].favouritesSymbol,
          favouritesCompanyType: _sortedFaveList[index].favouritesCompanyType,
          favouritesNetAssetValue: _sortedFaveList[index].favouritesNetAssetValue,
          favouritesCompanyYearlyRating: _sortedFaveList[index].favouritesCompanyYearlyRating,
          favouritesCompanyYearlyRisk: _sortedFaveList[index].favouritesCompanyYearlyRisk,
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
        type: "reksadana",
      ).then((resp) {
        Log.success(message: "➕ Add reksadana company ID: ${_sortedFaveList[index].favouritesCompanyId} for company ${_sortedFaveList[index].favouritesCompanyName}");
        
        FavouritesListModel ret = FavouritesListModel(
          favouritesCompanyId: _sortedFaveList[index].favouritesCompanyId,
          favouritesCompanyName: _sortedFaveList[index].favouritesCompanyName,
          favouritesSymbol: _sortedFaveList[index].favouritesSymbol,
          favouritesCompanyType: _sortedFaveList[index].favouritesCompanyType,
          favouritesNetAssetValue: _sortedFaveList[index].favouritesNetAssetValue,
          favouritesCompanyYearlyRating: _sortedFaveList[index].favouritesCompanyYearlyRating,
          favouritesCompanyYearlyRisk: _sortedFaveList[index].favouritesCompanyYearlyRisk,
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
      _faveList.clear();
      _faveList = List<FavouritesListModel>.from(list);
    });
  }

  void _setFilterList(List<FavouritesListModel> list) {
    setState(() {
      _filterFaveList.clear();
      _filterFaveList = List<FavouritesListModel>.from(list);
      _sortedFave();
    });
  }

  Future<void> _getUserFavourites() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get user reksadana favourites
    await _faveAPI.getFavourites(type: "reksadana").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList("reksadana", resp);
      // notify the provider
      if (!mounted) return;
      Provider.of<FavouritesProvider>(
        context,
        listen: false
      ).setFavouriteList(
        type: "reksadana",
        favouriteListData: resp,
      );
    });

    // remove loading screen
    LoadingScreen.instance().hide();
  }

  Future<bool> _getInitData() async {
    await _faveAPI.listFavouritesCompanies(type: "reksadana").then((resp) {
      _setFavouriteList(resp);
      _setFilterList(resp);
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting reksadana favourite list',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get reksadana favourite list');
    },);

    return true;
  }
}