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
  
  bool _isShowedLots = false;
  bool _isSummaryVisible = false;

  double _totalDayGain = 0;
  double _totalValue = 0;
  double _totalCost = 0;

  double _totalDayGainReksadana = 0;
  double _totalValueReksadana = 0;
  double _totalCostReksadana = 0;

  double _totalDayGainSaham = 0;
  double _totalValueSaham = 0;
  double _totalCostSaham = 0;
  
  double _totalDayGainCrypto = 0;
  double _totalValueCrypto = 0;
  double _totalCostCrypto = 0;

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlistReksadana = WatchlistSharedPreferences.getWatchlist("reksadana");
    _watchlistSaham = WatchlistSharedPreferences.getWatchlist("saham");
    _watchlistCrypto = WatchlistSharedPreferences.getWatchlist("crypto");

    _isSummaryVisible = _userInfo!.visibility;
    _isShowedLots = _userInfo!.showLots;
    _tabController = TabController(length: 3, vsync: this);
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

        _compute(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistSummary(
              dayGain: _totalDayGain,
              value: _totalValue,
              cost: _totalCost,
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
                    tabs: const <Widget>[
                      Tab(text: 'MUTUAL',),
                      Tab(text: 'STOCK',),
                      Tab(text: 'CRYPTO',),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        (_watchlistReksadana!.isNotEmpty ? _generateWatchlistItem("reksadana", _watchlistReksadana, _totalDayGainReksadana, _totalCostReksadana, _totalValueReksadana) : const Center(child: Text("No mutual fund watchlists"))),
                        (_watchlistSaham!.isNotEmpty ? _generateWatchlistItem("saham", _watchlistSaham, _totalDayGainSaham, _totalCostSaham, _totalValueSaham) : const Center(child: Text("No stock watchlists"))),
                        (_watchlistCrypto!.isNotEmpty ? _generateWatchlistItem("crypto", _watchlistCrypto, _totalDayGainCrypto, _totalCostCrypto, _totalValueCrypto) : const Center(child: Text("No crypto watchlists"))),
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

  Widget _generateWatchlistItem(String type, List<WatchlistListModel>? data, double dayGain, double cost, double value) {
    return RefreshIndicator(
      onRefresh: (() async {
        await _refreshWatchlist();
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
                    extentRatio: 0.7,
                    children: <Widget>[
                      SlidableAction(
                        onPressed: ((BuildContext context) {
                          if(data[idx].watchlistDetail.isNotEmpty) {
                            // only do when the list is not empty, otherwise there are nothing that need to be edited
                            Navigator.pushNamed(context, '/watchlist/detail/create', arguments: watchlistArgs);
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
                      isVisible: _isSummaryVisible,
                      watchlist: data[idx],
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

  void _compute(List<WatchlistListModel> watchlistsMutualfund, List<WatchlistListModel> watchlistsStock, List<WatchlistListModel> watchlistsCrypto) {
    // reset the value before we actually compute the data
    _totalDayGain = 0;
    _totalValue = 0;
    _totalCost = 0;   
    
    _totalDayGainReksadana = 0;
    _totalValueReksadana = 0;
    _totalCostReksadana = 0;

    _totalDayGainSaham = 0;
    _totalValueSaham = 0;
    _totalCostSaham = 0;

    _totalDayGainCrypto = 0;
    _totalValueCrypto = 0;
    _totalCostCrypto = 0;

    double dayGain = 0;
    double totalShare = 0;

    // loop thru all the mutual fund to get the total computation
    for (WatchlistListModel watchlist in watchlistsMutualfund) {
      // loop thru all the detail in watchlist
      totalShare = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        // compute all the detail data
        totalShare += detail.watchlistDetailShare;
        if (detail.watchlistDetailShare < 0) {
          // this is a sell, so we cannot use the price we sell as the cost
          // we should assume that the cost will be equal to the current price as the profit
          // taking we perform 2y ago, shouldn't affect the current cost
          _totalCostReksadana += (watchlist.watchlistCompanyNetAssetValue! * detail.watchlistDetailShare);
        }
        else {
          _totalCostReksadana += (detail.watchlistDetailPrice * detail.watchlistDetailShare);
        }
      }
      // get the day gain
      dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShare;
      
      // get the total value
      _totalDayGainReksadana += dayGain;
      _totalValueReksadana += totalShare * watchlist.watchlistCompanyNetAssetValue!;
    }

    // loop thru all the stock to get the total computation
    for (WatchlistListModel watchlist in watchlistsStock) {
      // loop thru all the detail in watchlist
      totalShare = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        // compute all the detail data
        totalShare += detail.watchlistDetailShare;
        if (detail.watchlistDetailShare < 0) {
          // this is a sell, so we cannot use the price we sell as the cost
          // we should assume that the cost will be equal to the current price as the profit
          // taking we perform 2y ago, shouldn't affect the current cost
          _totalCostSaham += (watchlist.watchlistCompanyNetAssetValue! * detail.watchlistDetailShare);
        }
        else {
          _totalCostSaham += (detail.watchlistDetailPrice * detail.watchlistDetailShare);
        }
      }
      // get the day gain
      dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShare;
      
      // get the total value
      _totalDayGainSaham += dayGain;
      _totalValueSaham += totalShare * watchlist.watchlistCompanyNetAssetValue!;
    }

    // loop thru all the crypto to get the total computation
    for (WatchlistListModel watchlist in watchlistsCrypto) {
      // loop thru all the detail in watchlist
      totalShare = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        // compute all the detail data
        totalShare += detail.watchlistDetailShare;
        if (detail.watchlistDetailShare < 0) {
          // this is a sell, so we cannot use the price we sell as the cost
          // we should assume that the cost will be equal to the current price as the profit
          // taking we perform 2y ago, shouldn't affect the current cost
          _totalCostCrypto += (watchlist.watchlistCompanyNetAssetValue! * detail.watchlistDetailShare);
        }
        else {
          _totalCostCrypto += (detail.watchlistDetailPrice * detail.watchlistDetailShare);
        }
      }
      // get the day gain
      dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * totalShare;
      
      // get the total value
      _totalDayGainCrypto += dayGain;
      _totalValueCrypto += totalShare * watchlist.watchlistCompanyNetAssetValue!;
    }

    _totalDayGain = _totalDayGainReksadana + _totalDayGainSaham + _totalDayGainCrypto;
    _totalValue = _totalValueReksadana + _totalValueSaham + _totalValueCrypto;
    _totalCost = _totalCostReksadana + _totalCostSaham + _totalCostCrypto;
  }

  Future<void> _refreshWatchlist() async {
    Future.wait([
      // get reksadana
      _watchlistAPI.getWatchlist("reksadana").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("reksadana", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("reksadana", resp);
        debugPrint("🔃 Refresh watchlist reksadana");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist reksadana");
      }),

      // get saham
      _watchlistAPI.getWatchlist("saham").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("saham", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("saham", resp);
        debugPrint("🔃 Refresh watchlist saham");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist saham");
      }),

      // get crypto
      _watchlistAPI.getWatchlist("crypto").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist("crypto", resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist("crypto", resp);
        debugPrint("🔃 Refresh watchlist crypto");
      }).onError((error, stackTrace) {
        throw Exception("❌ Error when refresh watchlist crypto");
      }),
    ]);
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