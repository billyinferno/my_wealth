import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/user_provider.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_add_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/function/compute_watchlist.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/expanded_tile_view.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/widgets/watchlist_sub_summary.dart';
import 'package:my_wealth/widgets/watchlist_summary.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class WatchlistsPage extends StatefulWidget {
  const WatchlistsPage({ Key? key }) : super(key: key);

  @override
  WatchlistsPageState createState() => WatchlistsPageState();
}

class WatchlistsPageState extends State<WatchlistsPage> with SingleTickerProviderStateMixin {
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  late TabController _tabController;
  late UserLoginInfoModel? _userInfo;
  late List<WatchlistListModel>? _watchlistReksadana;
  late List<WatchlistListModel>? _watchlistSaham;
  late List<WatchlistListModel>? _watchlistCrypto;
  late List<WatchlistListModel>? _watchlistGold;
  late ComputeWatchlistResult? _watchlistAll;
  
  bool _isShowedLots = false;
  bool _isSummaryVisible = false;

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlistReksadana = WatchlistSharedPreferences.getWatchlist("reksadana");
    _watchlistSaham = WatchlistSharedPreferences.getWatchlist("saham");
    _watchlistCrypto = WatchlistSharedPreferences.getWatchlist("crypto");
    _watchlistGold = WatchlistSharedPreferences.getWatchlist("gold");

    // sort the watchlist
    _watchlistReksadana = _sortWatchlist(_watchlistReksadana!);
    _watchlistSaham = _sortWatchlist(_watchlistSaham!);
    _watchlistCrypto = _sortWatchlist(_watchlistCrypto!);

    // initialize also in the initial state
    _watchlistAll = computeWatchlist(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

    _isSummaryVisible = _userInfo!.visibility;
    _isShowedLots = _userInfo!.showLots;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WatchlistProvider>(
      builder: ((context, userProvider, watchlistProvider, child) {
        _userInfo = userProvider.userInfo;
        _watchlistReksadana = watchlistProvider.watchlistReksadana;
        _watchlistSaham = watchlistProvider.watchlistSaham;
        _watchlistCrypto = watchlistProvider.watchlistCrypto;
        _watchlistGold = watchlistProvider.watchlistGold;

        // sort the watchlist
        _watchlistReksadana = _sortWatchlist(_watchlistReksadana!);
        _watchlistSaham = _sortWatchlist(_watchlistSaham!);
        _watchlistCrypto = _sortWatchlist(_watchlistCrypto!);

        // compute all the watchlist first
        _watchlistAll = computeWatchlist(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistSummary(
              dayGain: _watchlistAll!.totalDayGain,
              value: _watchlistAll!.totalValue,
              cost: _watchlistAll!.totalCost,
              riskFactor: _userInfo!.risk,
              visibility: _isSummaryVisible,
              onVisibilityPress: (() {
                setState(() {
                  _isSummaryVisible = !_isSummaryVisible;
                });
              }),
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Symbol",
                  icon: Ionicons.add_outline,
                  callback: (() {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: const Text(
                          "Add Watchlist",
                          style: TextStyle(
                            fontFamily: '--apple-system',
                          ),
                        ),
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // navigate to reksadana
                              WatchlistAddArgs args = WatchlistAddArgs(type: "reksadana");
                              Navigator.popAndPushNamed(context, '/watchlist/add', arguments: args);
                            }),
                            child: const Text(
                              "Mutual Fund",
                              style: TextStyle(
                                fontFamily: '--apple-system',
                                color: textPrimary,
                              ),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // navigate to reksadana
                              WatchlistAddArgs args = WatchlistAddArgs(type: "saham");
                              Navigator.popAndPushNamed(context, '/watchlist/add', arguments: args);
                            }),
                            child: const Text(
                              "Stock",
                              style: TextStyle(
                                fontFamily: '--apple-system',
                                color: textPrimary,
                              ),
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: (() {
                              // navigate to reksadana
                              WatchlistAddArgs args = WatchlistAddArgs(type: "crypto");
                              Navigator.popAndPushNamed(context, '/watchlist/add', arguments: args);
                            }),
                            child: const Text(
                              "Crypto",
                              style: TextStyle(
                                fontFamily: '--apple-system',
                                color: textPrimary,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Hide Lots",
                  icon: (_isShowedLots ? Ionicons.eye_outline : Ionicons.eye_off_outline),
                  callback: (() {
                    setState(() {
                      _isShowedLots = !_isShowedLots;
                    });
                  }),
                  active: _isShowedLots,
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const <Widget>[
                      Tab(text: 'MUTUAL',),
                      Tab(text: 'STOCK',),
                      Tab(text: 'GOLD'),
                      Tab(text: 'CRYPTO',),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        (_watchlistReksadana!.isNotEmpty ? _generateWatchlistItem("reksadana", _watchlistReksadana, _watchlistAll!.totalDayGainReksadana, _watchlistAll!.totalCostReksadana, _watchlistAll!.totalValueReksadana, false, "Share", false) : const Center(child: Text("No mutual fund watchlists"))),
                        (_watchlistSaham!.isNotEmpty ? _generateWatchlistItem("saham", _watchlistSaham, _watchlistAll!.totalDayGainSaham, _watchlistAll!.totalCostSaham, _watchlistAll!.totalValueSaham, true, "Lot", false) : const Center(child: Text("No stock watchlists"))),
                        (_watchlistGold!.isNotEmpty ? _generateWatchlistItem("gold", _watchlistGold, _watchlistAll!.totalDayGainGold, _watchlistAll!.totalCostGold, _watchlistAll!.totalValueGold, false, "Gram", true) : const Center(child: Text("Error while get gold watchlist"))),
                        (_watchlistCrypto!.isNotEmpty ? _generateWatchlistItem("crypto", _watchlistCrypto, _watchlistAll!.totalDayGainCrypto, _watchlistAll!.totalCostCrypto, _watchlistAll!.totalValueCrypto, false, "Coin", true) : const Center(child: Text("No crypto watchlists"))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _generateWatchlistItem(String type, List<WatchlistListModel>? data, double dayGain, double cost, double value, bool isInLot, String shareTitle, bool checkThousandOnPrice) {
    return RefreshIndicator(
      onRefresh: (() async {
        await _refreshWatchlist();
        // once finished rebuild widget
        setState(() {
          // just rebuild
        });
      }),
      color: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              itemCount: (data!.length + 1), // add 1 for the summary
              itemBuilder: ((context, index) {
                // for the first index we will return the summary
                if (index == 0) {
                  return WatchlistSubSummary(
                    dayGain: dayGain,
                    cost: cost,
                    value: value,
                    riskFactor: _userInfo!.risk,
                    isVisible: _isSummaryVisible,
                  );
                }
                
                // create the argumenst when open the company detail page
                // or the watchlist list page.
                int idx = index - 1;
                CompanyDetailArgs args = CompanyDetailArgs(
                  companyId: data[idx].watchlistCompanyId,
                  companyName: data[idx].watchlistCompanyName,
                  companyCode: (data[idx].watchlistCompanySymbol ?? ''),
                  companyFavourite: (data[idx].watchlistFavouriteId > 0 ? true : false),
                  favouritesId: data[idx].watchlistFavouriteId,
                  type: type,
                );

                WatchlistListArgs watchlistArgs = WatchlistListArgs(
                  type: type,
                  watchList: data[idx]
                );

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.875,
                    children: <Widget>[
                      SlidableAction(
                        onPressed: ((BuildContext context) {
                          if(data[idx].watchlistDetail.isNotEmpty) {
                            // only do when the list is not empty, otherwise there are nothing that need to be edited
                            Navigator.pushNamed(context, '/watchlist/detail/buy', arguments: watchlistArgs);
                          }
                        }),
                        icon: Ionicons.add,
                        backgroundColor: primaryColor,
                        foregroundColor: extendedLight,
                      ),
                      SlidableAction(
                        onPressed: ((BuildContext context) {
                          if(data[idx].watchlistDetail.isNotEmpty) {
                            // only do when the list is not empty, otherwise there are nothing that need to be edited
                            Navigator.pushNamed(context, '/watchlist/list', arguments: watchlistArgs);
                          }
                        }),
                        icon: Ionicons.ellipsis_horizontal,
                        backgroundColor: primaryColor,
                        foregroundColor: (data[idx].watchlistDetail.isNotEmpty ? accentColor : primaryLight),
                      ),
                      SlidableAction(
                        onPressed: ((BuildContext context) {
                          if(data[idx].watchlistDetail.isNotEmpty) {
                            // only do when the list is not empty, otherwise there are nothing that need to be edited
                            Navigator.pushNamed(context, '/watchlist/performance', arguments: watchlistArgs);
                          }
                        }),
                        icon: Ionicons.pulse_outline,
                        backgroundColor: primaryColor,
                        foregroundColor: (data[idx].watchlistDetail.isNotEmpty ? Colors.purple : primaryLight),
                      ),
                      SlidableAction(
                        onPressed: ((BuildContext context) {
                          Navigator.pushNamed(context, '/company/detail/$type', arguments: args);
                        }),
                        icon: Ionicons.open_outline,
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.green,
                      ),
                      SlidableAction(
                        onPressed: ((BuildContext context) async {
                          await ShowMyDialog(
                            title: "Delete Watchlist",
                            text: "Are you sure want to delete ${data[idx].watchlistCompanyName}?",
                            confirmLabel: "Delete",
                            cancelLabel: "Cancel"
                          ).show(context).then((resp) async {
                            if(resp!) {
                              // delete the watchlist
                              await _deleteWatchlist(type, data[idx].watchlistId).then((value) {
                                debugPrint("🗑️ Delete Watchlist ${data[idx].watchlistCompanyName}");
                              }).onError((error, stackTrace) {
                                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                              });
                            }
                          });
                        }),
                        icon: Ionicons.trash_bin_outline,
                        backgroundColor: primaryColor,
                        foregroundColor: secondaryColor,
                      ),
                    ],
                  ),
                  child: InkWell(
                    onDoubleTap: (() {
                      Navigator.pushNamed(context, '/watchlist/list', arguments: watchlistArgs);
                    }),
                    child: ExpandedTileView(
                      key: Key("expansionTitle$idx"),
                      userInfo: _userInfo!,
                      showedLot: _isShowedLots,
                      isInLot: isInLot,
                      isVisible: _isSummaryVisible,
                      watchlist: data[idx],
                      shareTitle: shareTitle,
                      checkThousandOnPrice: checkThousandOnPrice,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWatchlist() async {
    showLoaderDialog(context);
    await Future.microtask((() async {
      // get reksadana
      await _watchlistAPI.getWatchlist("reksadana").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("reksadana", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("reksadana", resp);
        debugPrint("🔃 Refresh watchlist reksadana");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist reksadana");
      });

      // get saham
      await _watchlistAPI.getWatchlist("saham").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("saham", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("saham", resp);
        debugPrint("🔃 Refresh watchlist saham");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist saham");
      });

      // get crypto
      await _watchlistAPI.getWatchlist("crypto").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("crypto", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("crypto", resp);
        debugPrint("🔃 Refresh watchlist crypto");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist crypto");
      });

      // get gold
      await _watchlistAPI.getWatchlist("gold").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("gold", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("gold", resp);
        debugPrint("🔃 Refresh watchlist gold");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist gold");
      });
    })).whenComplete(() {
      Navigator.pop(context);
    });
  }

  List<WatchlistListModel> _sortWatchlist(List<WatchlistListModel> watchlist) {
    // sort the watch list based on whether it have stock left or not?
    List<WatchlistListModel> gotShareList = [];
    List<WatchlistListModel> emptyShareList = [];

    for(WatchlistListModel data in watchlist) {
      if(_isGotShare(data)) {
        gotShareList.add(data);
      }
      else {
        emptyShareList.add(data);
      }
    }

    List<WatchlistListModel> newList = [...gotShareList, ...emptyShareList];
    return newList; 
  }

  bool _isGotShare(WatchlistListModel data) {
    // loop thru the watchlist details and calculate the total share and total gain
    double totalShareBuy = 0;
    double totalShareSell = 0;
    
    for (WatchlistDetailListModel detail in data.watchlistDetail) {
      if (detail.watchlistDetailShare > 0) {
        totalShareBuy += detail.watchlistDetailShare;
      }
      else {
        totalShareSell += detail.watchlistDetailShare;
      }
    }

    // check we still have share left or not?
    if ((totalShareBuy + totalShareSell) > 0) {
      return true;
    }
    return false;
  }

  Future<void> _deleteWatchlist(String type, int watchlistId) async {
    // show loader
    showLoaderDialog(context);
    await _watchlistAPI.delete(watchlistId).then((resp) async {
      if(resp) {
        // filter out the watchlist that we already delete
        List<WatchlistListModel> newWatchlist = [];

        // Check what we want to delete
        if (type == "reksadana") {
          for (WatchlistListModel watch in _watchlistReksadana!) {
            if(watch.watchlistId != watchlistId) {
              newWatchlist.add(watch);
            }
          }
        }
        else if (type == "saham") {
          for (WatchlistListModel watch in _watchlistSaham!) {
            if(watch.watchlistId != watchlistId) {
              newWatchlist.add(watch);
            }
          }
        }
        else if (type == "crypto") {
          for (WatchlistListModel watch in _watchlistCrypto!) {
            if(watch.watchlistId != watchlistId) {
              newWatchlist.add(watch);
            }
          }
        }
        else if (type == "gold") {
          for (WatchlistListModel watch in _watchlistGold!) {
            if(watch.watchlistId != watchlistId) {
              newWatchlist.add(watch);
            }
          }
        }

        // update shared preferences and the provider
        await WatchlistSharedPreferences.setWatchlist(type, newWatchlist);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(type, newWatchlist);
      }
    }).onError((error, stackTrace) {
      // when error return the error to the caller
      throw Exception(error);
    }).whenComplete(() {
      // remove loader
      Navigator.pop(context);
    });
  }
}