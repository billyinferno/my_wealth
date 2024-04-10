import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/model/favourites/favourites_list_model.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_favourites.dart';
import 'package:my_wealth/widgets/components/search_box.dart';
import 'package:my_wealth/widgets/list/favourite_company_list.dart';
import 'package:provider/provider.dart';

class FavouriteCompanyListSahamPage extends StatefulWidget {
  const FavouriteCompanyListSahamPage({super.key});

  @override
  State<FavouriteCompanyListSahamPage> createState() => _FavouriteCompanyListSahamPageState();
}

class _FavouriteCompanyListSahamPageState extends State<FavouriteCompanyListSahamPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dt = DateFormat("dd/MM/yyyy");

  late String _filterMode;
  late String _filterSort;
  final Map<String, String> _filterList = {};

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterFaveList = [];
  List<FavouritesListModel> _sortedFaveList = [];


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

    // default filter mode to Code and ASC
    _filterMode = "nm";
    _filterSort = "ASC";

    Future.microtask(() async {
      // once widget all load, showed the loader dialog since we will
      // perform API call to get the favorite company list
      showLoaderDialog(context);

      // get the company for favourite list
      await getFavouriteCompanyList().then((_) {
        // pop out the loader once API call finished
        Navigator.pop(context);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        // pop out the loader once API call finished
        Navigator.pop(context);
      });
    });
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
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
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
                showLoaderDialog(context);
                await getUserFavourites().then((_) {
                  // remove the loader
                  Navigator.pop(context);
                }).onError((error, stackTrace) {
                  // in case error showed it on debug
                  debugPrint(error.toString());
                  // remove the loader
                  Navigator.pop(context);
                }).whenComplete(() {
                  // return back to the previous page
                  Navigator.pop(context);
                });
              }),
            ),
          ),
          body: Column(
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
                    sortedFaveList();
                  });
                }),
                onSortSelect: ((value) {
                  setState(() {
                    _filterSort = value;
                    sortedFaveList();
                  });
                })
              ),
              const SizedBox(height: 10,),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: CupertinoSearchTextField(
                  controller: _textController,
                  onChanged: ((value) {
                    if (value.length >= 3) {
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
                        // debugPrint("Open Company ${_filterList[index].favouritesCompanyName}");
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
                        date: (_sortedFaveList[index].favouritesLastUpdate == null ? "-" : _dt.format(_sortedFaveList[index].favouritesLastUpdate!.toLocal())),
                        value: _sortedFaveList[index].favouritesNetAssetValue,
                        isFavourite: ((_sortedFaveList[index].favouritesUserId ?? -1) > 0 ? true : false),
                        fca: (_sortedFaveList[index].favouritesFCA ?? false),
                        subWidget: _subInfoWidget(_sortedFaveList[index]),
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

  void sortedFaveList() {
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

  void searchList(String find) {
    // clear the filter list first
    _filterFaveList.clear();
    // then loop thru _faveList and check if the company name or code contain the text we want to find
    for (var i = 0; i < _faveList.length; i++) {
      if (_faveList[i].favouritesCompanyName.toLowerCase().contains(find.toLowerCase()) || _faveList[i].favouritesSymbol.toLowerCase().contains(find.toLowerCase())) {
        // add this filter list
        _filterFaveList.add(_faveList[i]);
      }
    }
    sortedFaveList();
  }

  void updateFaveList(int index, FavouritesListModel resp) {
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

  Future<void> setFavourite(int index) async {
    // check if this is already favourite or not?
    int faveUserId = _sortedFaveList[index].favouritesUserId ?? -1;
    int faveId = _sortedFaveList[index].favouritesId ?? -1;
    if (faveUserId > 0 && faveId > 0) {
      // already favourite, delete the favourite
      await _faveAPI.delete(faveId).then((_) {
        debugPrint("🧹 Delete Favourite ID $faveId for stock company ${_sortedFaveList[index].favouritesCompanyName}");
        
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

        // update the list and re-render the page
        updateFaveList(index, resp);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to delete favourites"));
      });
    }
    else {
      await _faveAPI.add(_sortedFaveList[index].favouritesCompanyId, "saham").then((resp) {
        debugPrint("➕ Add stock company ID: ${_sortedFaveList[index].favouritesCompanyId} for company ${_sortedFaveList[index].favouritesCompanyName}");
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

        updateFaveList(index, ret);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to add favourites"));
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
      _filterFaveList = List<FavouritesListModel>.from(list);
      sortedFaveList();
    });
  }

  Future<void> getFavouriteCompanyList() async {
    await _faveAPI.listFavouritesCompanies("saham").then((resp) {
      setFavouriteList(resp);
      setFilterList(resp);
    });
  }

  Future<void> getUserFavourites() async {
    await _faveAPI.getFavourites("saham").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList("saham", resp);
      // notify the provider
      if (!mounted) return;
      Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("saham", resp);
    });
  }
}