import 'package:easy_sticky_header/easy_sticky_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistsPage extends StatefulWidget {
  const WatchlistsPage({ super.key });

  @override
  WatchlistsPageState createState() => WatchlistsPageState();
}

class WatchlistsPageState extends State<WatchlistsPage> with SingleTickerProviderStateMixin {
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final ScrollController _scrollControllerMutual = ScrollController();
  final ScrollController _scrollControllerStock = ScrollController();
  final ScrollController _scrollControllerCrypto = ScrollController();
  final ScrollController _scrollControllerGold = ScrollController();
  final ScrollController _scrollControllerHistory = ScrollController();
  final TextStyle _historyStyle = const TextStyle(fontSize: 11, color: textPrimary);

  late TabController _tabController;
  late UserLoginInfoModel? _userInfo;
  late List<WatchlistListModel>? _watchlistReksadana;
  late List<WatchlistListModel>? _watchlistSaham;
  late List<WatchlistListModel>? _watchlistCrypto;
  late List<WatchlistListModel>? _watchlistGold;
  late List<WatchlistHistoryModel>? _watchlistHistory;
  late ComputeWatchlistAllResult? _watchlistAll;
  late List<ComputeWatchlistResult> _watchlistResultReksadana;
  late List<ComputeWatchlistResult> _watchlistResultSaham;
  late List<ComputeWatchlistResult> _watchlistResultCrypto;
  late List<ComputeWatchlistResult> _watchlistResultGold;
  late CompanyLastUpdateModel _companyMaxLastUpdate;

  bool _isShowedLots = false;
  bool _isSummaryVisible = false;
  bool _isShowEmptyWatchlist = true;
  
  // hold the information for the current user configuration
  bool _currentIsShowedLots = false;
  bool _currentIsSummaryVisible = false;
  bool _currentIsShowEmptyWatchlist = true;

  @override
  void initState() {
    super.initState();
    _userInfo = UserSharedPreferences.getUserInfo();
    _watchlistReksadana = WatchlistSharedPreferences.getWatchlist(type: "reksadana");
    _watchlistSaham = WatchlistSharedPreferences.getWatchlist(type: "saham");
    _watchlistCrypto = WatchlistSharedPreferences.getWatchlist(type: "crypto");
    _watchlistGold = WatchlistSharedPreferences.getWatchlist(type: "gold");
    _watchlistHistory = WatchlistSharedPreferences.getWatchlistHistory();
    _companyMaxLastUpdate = CompanySharedPreferences.getCompanyLastUpdateModel(type: CompanyLastUpdateType.max);

    // sort the watchlist
    _watchlistReksadana = _sortWatchlist(_watchlistReksadana!);
    _watchlistSaham = _sortWatchlist(_watchlistSaham!);
    _watchlistCrypto = _sortWatchlist(_watchlistCrypto!);

    // initialize also in the initial state
    _watchlistAll = computeWatchlistAll(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

    // compute all the watchlist detail
    _watchlistResultReksadana = computeWatchlistDetail(watchlistList: _watchlistReksadana!, userInfo: _userInfo!);
    _watchlistResultSaham = computeWatchlistDetail(watchlistList: _watchlistSaham!, userInfo: _userInfo!);
    _watchlistResultCrypto = computeWatchlistDetail(watchlistList: _watchlistCrypto!, userInfo: _userInfo!);
    _watchlistResultGold = computeWatchlistDetail(watchlistList: _watchlistGold!, userInfo: _userInfo!);

    _isSummaryVisible = _userInfo!.visibility;
    _isShowedLots = _userInfo!.showLots;
    _isShowEmptyWatchlist = _userInfo!.showEmptyWatchlist;

    // get the current user information configuration during init stage
    _currentIsSummaryVisible = _userInfo!.visibility;
    _currentIsShowedLots = _userInfo!.showLots;
    _currentIsShowEmptyWatchlist = _userInfo!.showEmptyWatchlist;

    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollControllerMutual.dispose();
    _scrollControllerStock.dispose();
    _scrollControllerCrypto.dispose();
    _scrollControllerGold.dispose();
    _scrollControllerHistory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WatchlistProvider>(
      builder: ((context, userProvider, watchlistProvider, child) {
        _userInfo = userProvider.userInfo;

        // ensure user info is not null
        if (_userInfo != null) {
          // check if the current user information stored during init is
          // different with the one we got now?
          // if different then change the value of the variable used for control
          // the configuration on the page

          // check the visibility configuration
          if (_currentIsSummaryVisible != _userInfo!.visibility) {
            _currentIsSummaryVisible = _userInfo!.visibility;
            _isSummaryVisible = _userInfo!.visibility;
          }

          // check the show lots configuration
          if (_currentIsShowedLots != _userInfo!.showLots) {
            _currentIsShowedLots = _userInfo!.showLots;
            _isShowedLots = _userInfo!.showLots;
          }

          // check the show empty watch list configuration
          if (_currentIsShowEmptyWatchlist != _userInfo!.showEmptyWatchlist) {
            _currentIsShowEmptyWatchlist = _userInfo!.showEmptyWatchlist;
            _isShowEmptyWatchlist = _userInfo!.showEmptyWatchlist;
          }
        }

        // get all the watchlist information
        _watchlistReksadana = watchlistProvider.watchlistReksadana;
        _watchlistSaham = watchlistProvider.watchlistSaham;
        _watchlistCrypto = watchlistProvider.watchlistCrypto;
        _watchlistGold = watchlistProvider.watchlistGold;
        _watchlistHistory = watchlistProvider.watchlistHistory;

        // sort the watchlist
        _watchlistReksadana = _sortWatchlist(_watchlistReksadana!);
        _watchlistSaham = _sortWatchlist(_watchlistSaham!);
        _watchlistCrypto = _sortWatchlist(_watchlistCrypto!);

        // compute all the watchlist first
        _watchlistAll = computeWatchlistAll(_watchlistReksadana!, _watchlistSaham!, _watchlistCrypto!, _watchlistGold!);

        // compute all the watchlist detail
        _watchlistResultReksadana = computeWatchlistDetail(watchlistList: _watchlistReksadana!, userInfo: _userInfo!);
        _watchlistResultSaham = computeWatchlistDetail(watchlistList: _watchlistSaham!, userInfo: _userInfo!);
        _watchlistResultCrypto = computeWatchlistDetail(watchlistList: _watchlistCrypto!, userInfo: _userInfo!);
        _watchlistResultGold = computeWatchlistDetail(watchlistList: _watchlistGold!, userInfo: _userInfo!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            WatchlistSummary(
              context: context,
              dayGain: _watchlistAll!.totalDayGain,
              value: _watchlistAll!.totalValue,
              cost: _watchlistAll!.totalCost,
              riskFactor: _userInfo!.risk,
              visibility: _isSummaryVisible,
              compResult: _watchlistAll,
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
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: Ionicons.add_outline,
                  onTap: (() {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: ((BuildContext context) {
                        return MySafeArea(
                          child: CupertinoActionSheet(
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
                    );
                  }),
                ),
                const SizedBox(width: 5,),
                TransparentButton(
                  text: "${_isShowedLots ? 'Show' : 'Hide'} Lots",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: (_isShowedLots ? Ionicons.eye_outline : Ionicons.eye_off_outline),
                  onTap: (() {
                    setState(() {
                      _isShowedLots = !_isShowedLots;
                    });
                  }),
                  active: _isShowedLots,
                ),
                const SizedBox(width: 5,),
                TransparentButton(
                  text: "${_isShowEmptyWatchlist ? 'Show' : 'Hide'} Empty",
                  color: primaryDark,
                  borderColor: primaryLight,
                  icon: (_isShowEmptyWatchlist ? Ionicons.eye_outline : Ionicons.eye_off_outline),
                  onTap: (() {
                    setState(() {
                      _isShowEmptyWatchlist = !_isShowEmptyWatchlist;
                    });
                  }),
                  active: _isShowEmptyWatchlist,
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
                    tabAlignment: TabAlignment.start,
                    indicatorColor: accentColor,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: textPrimary,
                    unselectedLabelColor: textPrimary,
                    dividerHeight: 0,
                    tabs: const <Widget>[
                      Tab(text: 'MUTUAL',),
                      Tab(text: 'STOCK',),
                      Tab(text: 'CRYPTO',),
                      Tab(text: 'GOLD'),
                      Tab(icon: Icon(
                          Ionicons.document_text,
                          size: 12,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        _generateReksadana(),
                        _generateSaham(),
                        _generateCrypto(),
                        _generateGold(),
                        _generateHistory(),
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

  Widget _generateReksadana() {
    if (_watchlistReksadana!.isNotEmpty) {
      return _generateWatchlistItem(
        type: "reksadana",
        data: _watchlistReksadana,
        result: _watchlistResultReksadana,
        dayGain: _watchlistAll!.totalDayGainReksadana,
        cost: _watchlistAll!.totalCostReksadana,
        value: _watchlistAll!.totalValueReksadana,
        isInLot: false,
        shareTitle: "Share",
        checkThousandOnPrice: false,
        scrollController: _scrollControllerMutual,
        checkLastUpdate: true,
        lastUpdate: _companyMaxLastUpdate.reksadana,
        warningIcon: Ionicons.pause,
      );
    }
    return const Center(child: Text("No mutual fund watchlists"));
  }

  Widget _generateSaham() {
    if (_watchlistSaham!.isNotEmpty) {
      return _generateWatchlistItem(
        type: "saham",
        data: _watchlistSaham,
        result: _watchlistResultSaham,
        dayGain: _watchlistAll!.totalDayGainSaham,
        cost: _watchlistAll!.totalCostSaham,
        value: _watchlistAll!.totalValueSaham,
        isInLot: true,
        shareTitle: "Lot",
        checkThousandOnPrice: false,
        scrollController: _scrollControllerStock,
        showDecimalPrice: false,
        checkLastUpdate: true,
        lastUpdate: _companyMaxLastUpdate.saham,
        warningIcon: Ionicons.pause,
      );
    }
    return const Center(child: Text("No stock watchlists"));
  }

  Widget _generateCrypto() {
    if (_watchlistCrypto!.isNotEmpty) {
      return _generateWatchlistItem(
        type: "crypto",
        data: _watchlistCrypto,
        result: _watchlistResultCrypto,
        dayGain: _watchlistAll!.totalDayGainCrypto,
        cost: _watchlistAll!.totalCostCrypto,
        value: _watchlistAll!.totalValueCrypto,
        isInLot: false,
        shareTitle: "Coin",
        checkThousandOnPrice: true,
        scrollController: _scrollControllerCrypto,
        checkLastUpdate: true,
        lastUpdate: _companyMaxLastUpdate.crypto,
        warningIcon: Ionicons.pause,
      );
    }
    return const Center(child: Text("No crypto watchlists"));
  }

  Widget _generateGold() {
    if (_watchlistGold!.isNotEmpty) {
      return _generateWatchlistItem(
        type: "gold",
        data: _watchlistGold,
        result: _watchlistResultGold,
        dayGain: _watchlistAll!.totalDayGainGold,
        cost: _watchlistAll!.totalCostGold,
        value:  _watchlistAll!.totalValueGold,
        isInLot: false,
        shareTitle: "Gram",
        checkThousandOnPrice: true,
        scrollController: _scrollControllerGold,
      );
    }
    return const Center(child: Text("Error while get gold watchlist"));
  }

  Widget _generateHistory() {
    if (_watchlistHistory!.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: (() async {
          await _refreshWatchlist().onError((error, stackTrace) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
            }
          },).whenComplete(() {            
            // once finished rebuild widget
            setState(() {
              // just rebuild
            });
          },);
        }),
        color: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollControllerHistory,
                itemCount: (_watchlistHistory!.length),
                itemBuilder: ((context, index) {
                  String type = "";
                  switch(_watchlistHistory![index].watchlistType) {
                    case 'reksadana':
                      type = "Mutual Fund";
                      break;
                    case 'saham':
                      type = "Stock";
                      break;
                    case 'crypto':
                      type = "Crypto";
                      break;
                    default:
                      type = "";
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid
                        )
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          (_watchlistHistory![index].watchlistDetailShare < 0 ? Ionicons.remove_circle : Ionicons.add_circle),
                          color: (_watchlistHistory![index].watchlistDetailShare < 0 ? secondaryColor : Colors.green),
                          size: 15,
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: _watchlistHistory![index].watchlistDetailShare < 0 ? "Sell": "Buy",
                              style: _historyStyle,
                              children: <TextSpan>[
                                TextSpan(
                                  text: (type.isNotEmpty ? " $type " : " ")
                                ),
                                TextSpan(
                                  text: _watchlistHistory![index].companyName,
                                  style: _historyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: " for ",
                                ),
                                TextSpan(
                                  text: formatDecimal(
                                    _watchlistHistory![index].watchlistDetailShare.makePositive(),
                                    decimal: 2,
                                  ),
                                  style: _historyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: "@"),
                                TextSpan(
                                  text: formatCurrency(_watchlistHistory![index].watchlistDetailPrice),
                                  style: _historyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: " (${
                                    formatCurrency(
                                      _watchlistHistory![index].watchlistDetailShare.makePositive() *
                                      _watchlistHistory![index].watchlistDetailPrice
                                    )
                                  })",
                                  style: _historyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: " at "),
                                TextSpan(
                                  text: Globals.dfddMMyyyy.formatLocal(_watchlistHistory![index].watchlistDetailDate),
                                  style: _historyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text("Error while get gold watchlist"));
  }

  Widget _generateWatchlistItem({
    required String type,
    List<WatchlistListModel>? data,
    List<ComputeWatchlistResult>? result,
    required double dayGain,
    required double cost,
    required double value, 
    required bool isInLot,
    required String shareTitle,
    required bool checkThousandOnPrice,
    required ScrollController scrollController,
    bool? showDecimalPrice,
    bool checkLastUpdate = false,
    DateTime? lastUpdate,
    IconData warningIcon = Ionicons.warning,
    Color warningColor = secondaryColor,
  }) {
    // check if we have last update or not?
    final DateTime currentLastUpdate = (lastUpdate ?? DateTime.now());

    return RefreshIndicator(
      onRefresh: (() async {
        await _refreshWatchlist().then((_) {  
          // if success just rebuild the page
          setState(() {
          });
        },).onError((error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
          }
        },);
      }),
      color: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: StickyHeader(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: (data!.length + 1), // add 1 for the summary
                itemBuilder: ((context, index) {
                  // for the first index we will return the summary
                  if (index == 0) {
                    return StickyContainerWidget(
                      index: index,
                      child: Container(
                        color: primaryColor,
                        child: WatchlistSubSummary(
                          dayGain: dayGain,
                          cost: cost,
                          value: value,
                          riskFactor: _userInfo!.risk,
                          isVisible: _isSummaryVisible,
                          type: type,
                          totalData: data.length,
                          compResult: _watchlistAll,
                        ),
                      ),
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
                    watchlist: data[idx],
                    shareName: shareTitle,
                    isLot: isInLot,
                  );

                  bool isWarning = false;

                  // check if we need to check last update date or not?
                  if (checkLastUpdate) {
                    // check current last update for this watchlist
                    if (data[idx].watchlistCompanyLastUpdate != null) {
                      // compare the company last update
                      if (data[idx].watchlistCompanyLastUpdate!.isBeforeDate(date: currentLastUpdate)) {
                        isWarning = true;
                      }
                    } 
                  }
              
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 1,
                      children: <Widget>[
                        SlideButton(
                          icon: Ionicons.add,
                          iconColor: extendedLight,
                          onTap: () {
                            Navigator.pushNamed(context, '/watchlist/detail/buy', arguments: watchlistArgs);
                          },
                        ),
                        SlideButton(
                          icon: Ionicons.ellipsis_horizontal,
                          iconColor: (data[idx].watchlistDetail.isNotEmpty ? accentColor : primaryLight),
                          onTap: () {
                            if(data[idx].watchlistDetail.isNotEmpty) {
                              // only do when the list is not empty, otherwise there are nothing that need to be edited
                              Navigator.pushNamed(context, '/watchlist/list', arguments: watchlistArgs);
                            }
                          },
                        ),
                        SlideButton(
                          icon: Ionicons.pulse_outline,
                          iconColor: (data[idx].watchlistDetail.isNotEmpty ? Colors.purple : primaryLight),
                          onTap: () {
                            if(data[idx].watchlistDetail.isNotEmpty) {
                              // only do when the list is not empty, otherwise there are nothing that need to be showed as performance
                              Navigator.pushNamed(context, '/watchlist/performance', arguments: watchlistArgs);
                            }
                          },
                        ),
                        SlideButton(
                          icon: Ionicons.calendar_outline,
                          iconColor: (data[idx].watchlistDetail.isNotEmpty ? Colors.pink[300]! : primaryLight),
                          onTap: () {
                            if(data[idx].watchlistDetail.isNotEmpty) {
                              Navigator.pushNamed(context, '/watchlist/calendar', arguments: watchlistArgs);
                            }
                          },
                        ),
                        SlideButton(
                          icon: Ionicons.business_outline,
                          iconColor: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, '/company/detail/$type', arguments: args);
                          },
                        ),
                        SlideButton(
                          icon: Ionicons.trash_bin_outline,
                          iconColor: secondaryColor,
                          onTap: () async {
                            await ShowMyDialog(
                              title: "Delete Watchlist",
                              text: "Are you sure want to delete ${data[idx].watchlistCompanyName}?",
                              confirmLabel: "Delete",
                              cancelLabel: "Cancel"
                            ).show(context).then((resp) async {
                              if(resp!) {
                                // delete the watchlist
                                await _deleteWatchlist(type, data[idx].watchlistId).then((value) {
                                  Log.success(message: "🗑️ Delete Watchlist ${data[idx].watchlistCompanyName}");
                                }).onError((error, stackTrace) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                                  }
                                });
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    child: InkWell(
                      onDoubleTap: (() {
                        Navigator.pushNamed(context, '/watchlist/list', arguments: watchlistArgs);
                      }),
                      child: ExpandedTileView(
                        key: Key("watchlist_${type}_${data[idx].watchlistCompanyId}"),
                        showedLot: _isShowedLots,
                        inLot: isInLot,
                        risk: _userInfo!.risk,
                        isVisible: _isSummaryVisible,
                        watchlist: data[idx],
                        watchlistResult: result![idx],
                        shareTitle: shareTitle,
                        checkThousandOnPrice: checkThousandOnPrice,
                        showEmptyWatchlist: _isShowEmptyWatchlist,
                        showPriceDecimal: (showDecimalPrice ?? true),
                        fca: (data[idx].watchlistCompanyFCA ?? false),
                        warning: isWarning,
                        warningIcon: warningIcon,
                        warningColor: warningColor,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshWatchlist() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the watchlist data
    await Future.wait([
      _watchlistAPI.getWatchlist(type: "reksadana").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist(
          type: "reksadana",
          watchlistData: resp
        );
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
          type: "reksadana",
          watchlistData: resp
        );
        Log.success(message: "🔃 Refresh watchlist reksadana");
      }),

      _watchlistAPI.getWatchlist(type: "saham").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist(
          type: "saham",
          watchlistData: resp
        );
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
          type: "saham",
          watchlistData: resp
        );
        Log.success(message: "🔃 Refresh watchlist saham");
      }),

       _watchlistAPI.getWatchlist(type: "crypto").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist(
          type: "crypto",
          watchlistData: resp
        );
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
          type: "crypto",
          watchlistData: resp
        );
        Log.success(message: "🔃 Refresh watchlist crypto");
      }),

      _watchlistAPI.getWatchlist(type: "gold").then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlist(
          type: "gold",
          watchlistData: resp
        );
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
          type: "gold",
          watchlistData: resp
        );
        Log.success(message: "🔃 Refresh watchlist gold");
      }),

      _watchlistAPI.getWatchlistHistory().then((resp) async {
        // update the provider and shared preferences
        await WatchlistSharedPreferences.setWatchlistHistory(watchlistData: resp);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlistHistory(watchlistData: resp);
        Log.success(message: "🔃 Refresh watchlist history");
      }),
    ]).onError((error, stackTrace) {
      throw Exception("Error when refresh watchlist");
    });

    // remove loading screen
    LoadingScreen.instance().hide();
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
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // delete the watchlist
    await _watchlistAPI.delete(watchlistId: watchlistId).then((resp) async {
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

        // delete company watchlist ID from company search cache
        await CompanySharedPreferences.deleteCompanySearch(
          type: type,
          watchlistID: watchlistId
        );

        // update shared preferences and the provider
        await WatchlistSharedPreferences.setWatchlist(
          type: type,
          watchlistData: newWatchlist
        );
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
          type: type,
          watchlistData: newWatchlist
        );
      }
    }).onError((error, stackTrace) {
      // when error return the error to the caller
      throw Exception(error);
    }).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    });
  }
}