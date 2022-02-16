import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/favourites_api.dart';
import 'package:my_wealth/model/favourites_list_model.dart';
import 'package:my_wealth/provider/favourites_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_favourites.dart';
import 'package:my_wealth/widgets/favourite_company_list.dart';
import 'package:my_wealth/widgets/stepper_selector.dart';
import 'package:my_wealth/widgets/stepper_selector_controller.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:provider/provider.dart';

class FavouriteCompanyListPage extends StatefulWidget {
  const FavouriteCompanyListPage({ Key? key }) : super(key: key);

  @override
  _FavouriteCompanyListPageState createState() => _FavouriteCompanyListPageState();
}

class _FavouriteCompanyListPageState extends State<FavouriteCompanyListPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dt = DateFormat("dd/MM/yyyy");
  final TextEditingController _textController = TextEditingController();
  final StepperSelectorController _stepperControllerRating = StepperSelectorController();
  final StepperSelectorController _stepperControllerRisk = StepperSelectorController();

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterList = [];
  bool _isFilter = false;
  bool _isSearch = false;
  int _filterType = -1;
  String _filterSearchText = "";
  int _filterSearchNum = -1;
  String _filterText = "";
  int _currentRatingNum = 5;
  int _currentRiskNum = 5;

  @override
  void initState() {
    super.initState();

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
    _scrollController.dispose();
    _textController.dispose();
    _stepperControllerRisk.dispose();
    _stepperControllerRating.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Add/Edit Favourites",
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
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CupertinoTextField(
                controller: _textController,
                cursorColor: secondaryColor,
                maxLines: 1,
                maxLength: 100,
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
            Row(
              children: [
                const SizedBox(width: 10,),
                TransparentButton(
                  icon: Ionicons.search,
                  text: (_isSearch ? "Clear" : "Search"),
                  callback: (() {
                    // ensure that we have the text we want to search
                    String _searchText = _textController.text.trim();
                    
                    // check whether search already activated or not?
                    if (_isSearch) {
                      // clear the search
                      setState(() {
                        _textController.text = "";
                        _filterList = _faveList;
                        _isSearch = false;
                      });
                    }
                    else {
                      if (_searchText.isNotEmpty) {
                        // search from the list
                        debugPrint("Search " + _searchText);
                        setSearch(_searchText);
                      }
                    }
                  }),
                  active: _isSearch,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  icon: Ionicons.funnel,
                  text: (_isFilter ? _filterText : "Filter"),
                  callback: (() {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: const Text(
                          "Filter List",
                          style: TextStyle(
                            fontFamily: '--apple-system',
                          ),
                        ),
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // clear search if available
                              _textController.text = "";
                              _filterList = _faveList;
                              _isSearch = false;

                              _filterType = 0;
                              _filterSearchText = "campuran";
                              _filterText = Globals.companyTypeEnum[_filterSearchText]!;
                              setFilter(true);
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              "Campuran",
                              style: TextStyle(
                                fontFamily: '--apple-system'
                              ),
                            )
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // clear search if available
                              _textController.text = "";
                              _filterList = _faveList;
                              _isSearch = false;
                              
                              _filterType = 0;
                              _filterSearchText = "saham";
                              _filterText = Globals.companyTypeEnum[_filterSearchText]!;
                              setFilter(true);
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              "Saham",
                              style: TextStyle(
                                fontFamily: '--apple-system'
                              ),
                            )
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // clear search if available
                              _textController.text = "";
                              _filterList = _faveList;
                              _isSearch = false;
                              
                              _filterType = 0;
                              _filterSearchText = "pasaruang";
                              _filterText = Globals.companyTypeEnum[_filterSearchText]!;
                              setFilter(true);
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              "Pasar Uang",
                              style: TextStyle(
                                fontFamily: '--apple-system'
                              ),
                            )
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // clear search if available
                              _textController.text = "";
                              _filterList = _faveList;
                              _isSearch = false;
                              
                              _filterType = 1;
                              _filterSearchNum = _stepperControllerRating.value!;
                              _currentRatingNum = _filterSearchNum;
                              _filterText = "Rating (" + _stepperControllerRating.value.toString() + ")";
                              setFilter(true);
                              Navigator.pop(context);
                            }),
                            child: StepperSelector(
                              controller: _stepperControllerRating,
                              title: "Rating",
                              titleSize: 20,
                              icon: Ionicons.star,
                              iconColor: accentColor,
                              defaultValue: _currentRatingNum,
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // clear search if available
                              _textController.text = "";
                              _filterList = _faveList;
                              _isSearch = false;
                              
                              _filterType = 2;
                              _filterSearchNum = _stepperControllerRisk.value!;
                              _currentRiskNum = _filterSearchNum;
                              _filterText = "Risk (" + _stepperControllerRisk.value.toString() + ")";
                              setFilter(true);
                              Navigator.pop(context);
                            }),
                            child: StepperSelector(
                              controller: _stepperControllerRisk,
                              title: "Risk",
                              titleSize: 20,
                              icon: Ionicons.alert,
                              iconColor: secondaryColor,
                              defaultValue: _currentRiskNum,
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              _filterText = "";
                              _filterSearchText = "";
                              setFilter(false);
                              Navigator.pop(context);
                            }),
                            child: const Text(
                              "Clear Filter",
                              style: TextStyle(
                                fontFamily: '--apple-system',
                                color: secondaryColor
                              ),
                            )
                          ),
                        ],
                      ),
                    );
                  }),
                  active: _isFilter,
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Showed " + _filterList.length.toString() + " company(s)",
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
                      CompanyDetailArgs _args = CompanyDetailArgs(
                        companyId: _filterList[index].favouritesCompanyId,
                        companyName: _filterList[index].favouritesCompanyName,
                        companyFavourite: ((_filterList[index].favouritesUserId ?? -1) > 0 ? true : false),
                        favouritesId: (_filterList[index].favouritesId ?? -1),
                      );

                      Navigator.pushNamed(context, '/company/detail', arguments: _args);
                    }),
                    child: FavouriteCompanyList(
                      companyId: _filterList[index].favouritesCompanyId,
                      name: _filterList[index].favouritesCompanyName,
                      type: Globals.companyTypeEnum[_filterList[index].favouritesCompanyType]!,
                      date: (_filterList[index].favouritesLastUpdate == null ? "-" : _dt.format(_filterList[index].favouritesLastUpdate!.toLocal())),
                      value: _filterList[index].favouritesNetAssetValue,
                      isFavourite: ((_filterList[index].favouritesUserId ?? -1) > 0 ? true : false),
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
    int _faveUserId = _filterList[index].favouritesUserId ?? -1;
    int _faveId = _filterList[index].favouritesId ?? -1;
    if (_faveUserId > 0 && _faveId > 0) {
      // already favourite, delete the favourite
      await _faveAPI.delete(_faveId).then((_) {
        debugPrint("🧹 Delete Favourite ID " + _faveId.toString() + " for company "+ _filterList[index].favouritesCompanyName);
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel _resp = FavouritesListModel(
          favouritesCompanyId: _filterList[index].favouritesCompanyId,
          favouritesCompanyName: _filterList[index].favouritesCompanyName,
          favouritesCompanyType: _filterList[index].favouritesCompanyType,
          favouritesNetAssetValue: _filterList[index].favouritesNetAssetValue,
          favouritesLastUpdate: _filterList[index].favouritesLastUpdate
        );

        // update the list and re-render the page
        updateFaveList(index, _resp);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to delete favourites"));
      });
    }
    else {
      await _faveAPI.add(_filterList[index].favouritesCompanyId).then((resp) {
        debugPrint("➕ add company ID: " + _filterList[index].favouritesCompanyId.toString() +  " for company " + _filterList[index].favouritesCompanyName);
        // update the list with the updated response and re-render the page
        updateFaveList(index, resp);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to add favourites"));
      });
    }
  }

  void setFilter(bool filter) {
    setState(() {
      if(filter) {
        // we need to filter the _filterList with _faveLis
        _filterList = [];
        // check whether this is type 0 (type), 1 (rating), 2 (risk)
        if (_filterType == 0) {
          for (var _fave in _faveList) {
            // check if the company type is the same as filter or not?
            if(_fave.favouritesCompanyType.toLowerCase() == _filterSearchText.toLowerCase()) {
              _filterList.add(_fave);
            }
          }
        }
        else if(_filterType == 1) {
          for (var _fave in _faveList) {
            // check if the company type is the same as filter or not?
            if(_fave.favouritesCompanyYearlyRating == _filterSearchNum) {
              _filterList.add(_fave);
            }
          }
        }
        else if(_filterType == 2) {
          for (var _fave in _faveList) {
            // check if the company type is the same as filter or not?
            if(_fave.favouritesCompanyYearlyRisk == _filterSearchNum) {
              _filterList.add(_fave);
            }
          }
        }
      }
      else {
        _filterList = _faveList;
      }
      _isFilter = filter;
    });
  }

  void setSearch(String searchText) {
    setState(() {
      _filterList = [];
      for (var _fave in _faveList) {
        // check if the company type is the same as filter or not?
        if(_fave.favouritesCompanyName.toLowerCase().contains(searchText.toLowerCase())) {
          _filterList.add(_fave);
        }
      }
      _isSearch = true;

      // clear filter if already set
      _filterText = "";
      _filterSearchText = "";
      setFilter(false);
    });
  }

  void setFavouriteList(List<FavouritesListModel> list) {
    setState(() {
      _faveList = list;
      _filterList = list;
    });
  }

  Future<void> getFavouriteCompanyList() async {
    await _faveAPI.listFavouritesCompanies().then((resp) {
      setFavouriteList(resp);
    });
  }

  Future<void> getUserFavourites() async {
    await _faveAPI.getFavourites().then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList(resp);
      // notify the provider
      Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList(resp);
    });
  }
}