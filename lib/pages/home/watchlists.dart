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
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/expanded_tile_view.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/widgets/watchlist_summary.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:provider/provider.dart';

class WatchlistsPage extends StatefulWidget {
  const WatchlistsPage({ Key? key }) : super(key: key);

  @override
  _WatchlistsPageState createState() => _WatchlistsPageState();
}

class _WatchlistsPageState extends State<WatchlistsPage> {
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final ScrollController _scrollController = ScrollController();
  late UserLoginInfoModel? _userInfo;
  late List<WatchlistListModel>? _watchlist;
  bool _isShowedLots = false;
  double _totalDayGain = 0;
  double _totalValue = 0;
  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlist = WatchlistSharedPreferences.getWatchlist();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WatchlistProvider>(
      builder: ((context, userProvider, watchlistProvider, child) {
        _userInfo = userProvider.userInfo;
        _watchlist = watchlistProvider.watchlist;

        _compute(_watchlist!);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistSummary(
              dayGain: _totalDayGain,
              value: _totalValue,
              cost: _totalCost,
              riskFactor: _userInfo!.risk
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
                    Navigator.pushNamed(context, '/watchlist/add');
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
              child: RefreshIndicator(
                onRefresh: (() async {
                  await _refreshWatchlist().then((resp) async {
                    // update the provider and shared preferences
                    await WatchlistSharedPreferences.setWatchlist(resp);
                    Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(resp);
                    debugPrint("🔃 Refresh watchlist");
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                    debugPrint("🛑 Error when refresh watchlist");
                  });
                }),
                color: accentColor,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: _watchlist!.length,
                  itemBuilder: ((context, index) {
                    CompanyDetailArgs _args = CompanyDetailArgs(
                      companyId: _watchlist![index].watchlistCompanyId,
                      companyName: _watchlist![index].watchlistCompanyName,
                      companyFavourite: (_watchlist![index].watchlistFavouriteId > 0 ? true : false),
                      favouritesId: _watchlist![index].watchlistFavouriteId,
                    );
                    
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: <Widget>[
                          SlidableAction(
                            onPressed: ((BuildContext context) {
                              if(_watchlist![index].watchlistDetail.isNotEmpty) {
                                // only do when the list is not empty, otherwise there are nothing that need to be edited
                                Navigator.pushNamed(context, '/watchlist/detail/create', arguments: _watchlist![index]);
                              }
                            }),
                            icon: Ionicons.add,
                            backgroundColor: primaryColor,
                            foregroundColor: extendedLight,
                          ),
                          SlidableAction(
                            onPressed: ((BuildContext context) {
                              if(_watchlist![index].watchlistDetail.isNotEmpty) {
                                // only do when the list is not empty, otherwise there are nothing that need to be edited
                                Navigator.pushNamed(context, '/watchlist/list', arguments: _watchlist![index]);
                              }
                            }),
                            icon: Ionicons.ellipsis_horizontal,
                            backgroundColor: primaryColor,
                            foregroundColor: (_watchlist![index].watchlistDetail.isNotEmpty ? accentColor : primaryLight),
                          ),
                          SlidableAction(
                            onPressed: ((BuildContext context) {
                              Navigator.pushNamed(context, '/company/detail', arguments: _args);
                            }),
                            icon: Ionicons.open_outline,
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.green,
                          ),
                          SlidableAction(
                            onPressed: ((BuildContext context) async {
                              await ShowMyDialog(
                                title: "Delete Watchlist",
                                text: "Are you sure want to delete " + _watchlist![index].watchlistCompanyName.toTitleCase() + "?",
                                confirmLabel: "Delete",
                                cancelLabel: "Cancel"
                              ).show(context).then((resp) async {
                                if(resp!) {
                                  // delete the watchlist
                                  await _deleteWatchlist(_watchlist![index].watchlistId).then((value) {
                                    debugPrint("🗑️ Delete Watchlist " + _watchlist![index].watchlistCompanyName.toTitleCase());
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
                          Navigator.pushNamed(context, '/watchlist/list', arguments: _watchlist![index]);
                        }),
                        child: ExpandedTileView(
                          key: Key("expansionTitle" + index.toString()),
                          userInfo: _userInfo!,
                          showedLot: _isShowedLots,
                          watchlist: _watchlist![index],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _compute(List<WatchlistListModel> watchlists) {
    _totalDayGain = 0;
    _totalValue = 0;
    _totalCost = 0;

    double _dayGain = 0;
    double _totalShare = 0;

    // loop thru all the watchlists to get the total computation
    for (WatchlistListModel watchlist in watchlists) {
      // loop thru all the detail in watchlist
      _totalShare = 0;
      for (WatchlistDetailListModel detail in watchlist.watchlistDetail) {
        // compute all the detail data
        _totalShare += detail.watchlistDetailShare;
        _totalCost += (detail.watchlistDetailPrice * detail.watchlistDetailShare);
      }
      // get the day gain
      _dayGain = (watchlist.watchlistCompanyNetAssetValue! - watchlist.watchlistCompanyPrevPrice!) * _totalShare;
      
      // get the total value
      _totalDayGain += _dayGain;
      _totalValue += _totalShare * watchlist.watchlistCompanyNetAssetValue!;
    }
  }

  Future<List<WatchlistListModel>> _refreshWatchlist() async {
    List<WatchlistListModel> _ret = [];
    await _watchlistAPI.getWatchlist().then((resp) {
      _ret = resp;
    }).onError((error, stackTrace) {
      throw Exception("Error when refresh watchlist;");
    });

    return _ret;
  }

  Future<void> _deleteWatchlist(int watchlistId) async {
    // show loader
    showLoaderDialog(context);
    await _watchlistAPI.delete(watchlistId).then((resp) async {
      if(resp) {
        // filter out the watchlist that we already delete
        List<WatchlistListModel> _newWatchlist = [];
        for (WatchlistListModel _watch in _watchlist!) {
          if(_watch.watchlistId != watchlistId) {
            _newWatchlist.add(_watch);
          }
        }

        // update shared preferences and the provider
        await WatchlistSharedPreferences.setWatchlist(_newWatchlist);
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_newWatchlist);
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