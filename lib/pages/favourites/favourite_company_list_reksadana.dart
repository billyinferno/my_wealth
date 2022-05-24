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
import 'package:provider/provider.dart';

class FavouriteCompanyListReksadanaPage extends StatefulWidget {
  const FavouriteCompanyListReksadanaPage({ Key? key }) : super(key: key);

  @override
  _FavouriteCompanyListReksadanaPageState createState() => _FavouriteCompanyListReksadanaPageState();
}

class _FavouriteCompanyListReksadanaPageState extends State<FavouriteCompanyListReksadanaPage> {
  final FavouritesAPI _faveAPI = FavouritesAPI();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dt = DateFormat("dd/MM/yyyy");
  final TextEditingController _textController = TextEditingController();
  final StepperSelectorController _stepperControllerRating = StepperSelectorController();
  final StepperSelectorController _stepperControllerRisk = StepperSelectorController();

  List<FavouritesListModel> _faveList = [];
  List<FavouritesListModel> _filterList = [];
  bool _isCampuran = true;
  bool _isSaham = true;
  bool _isPasarUang = true;
  bool _isPendapatanTetap = true;
  int _currentRatingNum = 0;
  int _currentRiskNum = 0;

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
      child: WillPopScope(
        onWillPop: (() async {
          return false;
        }),
        child: Scaffold(
          appBar: AppBar(
            title: const Center(
              child: Text(
                "Add Favourites Mutual Fund",
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
                                        activeColor: accentDark,
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
                                        activeColor: accentDark,
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
                                        activeColor: accentDark,
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
                                        activeColor: accentDark,
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
                          type: "reksadana",
                        );
      
                        Navigator.pushNamed(context, '/company/detail/reksadana', arguments: _args);
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
      ),
    );
  }

  void filterData() {
    // create a temporary list to hold resulted filter list
    List<FavouritesListModel> _result = [];
    String _find = _textController.text;

    // first let's filter all the type needed
    for (FavouritesListModel _fave in _faveList) {
      if (_isCampuran && _isPendapatanTetap && _isPasarUang && _isSaham) {
        _result.add(_fave);
      }
      else {
        // check the type first
        if(_fave.favouritesCompanyType == "reksadanacampuran" && _isCampuran) {
          _result.add(_fave);
        }
        if(_fave.favouritesCompanyType == "reksadanapendapatantetap" && _isPendapatanTetap) {
          _result.add(_fave);
        }
        if(_fave.favouritesCompanyType == "reksadanapasaruang" && _isPasarUang) {
          _result.add(_fave);
        }
        if(_fave.favouritesCompanyType == "reksadanasaham" && _isSaham) {
          _result.add(_fave);
        }
      }
    }

    // create a temporary list for moving the data
    List<FavouritesListModel> _temp = [];

    // now by right _result should be filled, we can now filter this based on the rating given
    if(_stepperControllerRating.value! > 0) {
      // duplicate the result
      _temp.clear();
      _temp = List<FavouritesListModel>.from(_result);
      _result.clear();

      for (FavouritesListModel _fave in _temp) {
        if (_fave.favouritesCompanyYearlyRating!.toInt() >= _stepperControllerRating.value!) {
          _result.add(_fave);
        }
      }
    }

    // now by right _result should be filled, we can now filter this based on the rating given
    if(_stepperControllerRisk.value! > 0) {
      // duplicate the result
      _temp.clear();
      _temp = List<FavouritesListModel>.from(_result);
      _result.clear();

      for (FavouritesListModel _fave in _temp) {
        if (_fave.favouritesCompanyYearlyRisk!.toInt() >= _stepperControllerRisk.value!) {
          _result.add(_fave);
        }
      }
    }

    // now check if the find text is more than 3 or not?
    if (_find.length >= 3) {
      // check if the name contain the text in find or not?
      // duplicate the result
      _temp.clear();
      _temp = List<FavouritesListModel>.from(_result);
      _result.clear();

      for (FavouritesListModel _fave in _temp) {
        if(_fave.favouritesCompanyName.toLowerCase().contains(_find.toLowerCase())) {
          _result.add(_fave);
        }
      }
    }

    // once finished, set the _filterList with result
    setFilterList(_result);
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
        debugPrint("🧹 Delete Favourite ID " + _faveId.toString() + " for reksadana company "+ _filterList[index].favouritesCompanyName);
        
        // remove the favouriteId and favouriteUserId to determine that this is not yet
        // favourited by user
        FavouritesListModel _resp = FavouritesListModel(
          favouritesCompanyId: _filterList[index].favouritesCompanyId,
          favouritesCompanyName: _filterList[index].favouritesCompanyName,
          favouritesSymbol: _filterList[index].favouritesSymbol,
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
      await _faveAPI.add(_filterList[index].favouritesCompanyId, "reksadana").then((resp) {
        debugPrint("➕ Add reksadana company ID: " + _filterList[index].favouritesCompanyId.toString() +  " for company " + _filterList[index].favouritesCompanyName);
        // update the list with the updated response and re-render the page
        updateFaveList(index, resp);
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Unable to add favourites"));
      });
    }
  }

  void setFavouriteList(List<FavouritesListModel> list) {
    setState(() {
      _faveList.clear();
      _faveList = List<FavouritesListModel>.from(list);
    });
  }

  void setFilterList(List<FavouritesListModel> list) {
    setState(() {
      _filterList.clear();
      _filterList = List<FavouritesListModel>.from(list);
    });
  }

  Future<void> getFavouriteCompanyList() async {
    await _faveAPI.listFavouritesCompanies("reksadana").then((resp) {
      setFavouriteList(resp);
      setFilterList(resp);
    });
  }

  Future<void> getUserFavourites() async {
    await _faveAPI.getFavourites("reksadana").then((resp) async {
      // update the shared preferences, and the provider
      await FavouritesSharedPreferences.setFavouritesList("reksadana", resp);
      // notify the provider
      Provider.of<FavouritesProvider>(context, listen: false).setFavouriteList("reksadana", resp);
    });
  }
}