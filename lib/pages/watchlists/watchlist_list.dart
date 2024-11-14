import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistListPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistListPage({ super.key, required this.watchlistArgs });

  @override
  WatchlistListPageState createState() => WatchlistListPageState();
}

class WatchlistListPageState extends State<WatchlistListPage> {
  final ScrollController _scrollController = ScrollController();
  final WatchlistAPI _watchlistApi = WatchlistAPI();

  late WatchlistListArgs _watchlistArgs;
  late String _type;
  late WatchlistListModel _watchlist;
  late UserLoginInfoModel? _userInfo;
  late CompanyDetailArgs? args;

  int _totalBuy = 0;
  int _totalSell = 0;
  double _priceDiff = 0;
  double _totalCost = 0;
  double _totalUnrealisedGain = 0;
  double _totalRealisedGain = 0;
  double _totalValue = 0;
  double _totalCurrentShares = 0;
  double _totalSharesBuy = 0;
  double _totalSharesSell = 0;
  double _totalBuyAmount = 0;
  double _totalSellAmount = 0;
  Color _riskColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _watchlistArgs = widget.watchlistArgs as WatchlistListArgs;
    _type = _watchlistArgs.type;
    _watchlist = _watchlistArgs.watchList;
    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Ionicons.arrow_back
            ),
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: (() {
                if (args != null) {
                  Navigator.pushNamed(context, '/company/detail/$_type', arguments: args);
                }
              }),
              icon: const Icon(
                Ionicons.business_outline
              ),
            ),
            IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, '/watchlist/performance', arguments: _watchlistArgs);
              }),
              icon: const Icon(
                Ionicons.pulse_outline
              ),
            ),
          ],
          title: const Center(
            child: Text(
              "Watchlist List",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
        ),
        body: MySafeArea(
          child: Consumer<WatchlistProvider>(
            builder: ((context, watchlistProvider, child) {
              // get the actual data of this watchlist from provider.
              // so when we refresh the provider, the watchlist will be updated also.
              if (_type == "reksadana") {
                for(WatchlistListModel watch in watchlistProvider.watchlistReksadana!) {
                  if(watch.watchlistCompanyId == _watchlist.watchlistCompanyId) {
                    _watchlist = watch;
                    args = CompanyDetailArgs(
                      companyId: _watchlist.watchlistCompanyId,
                      companyName: _watchlist.watchlistCompanyName,
                      companyCode: _watchlist.watchlistCompanySymbol!,
                      companyFavourite: (_watchlist.watchlistFavouriteId > 0 ? true : false),
                      favouritesId: _watchlist.watchlistFavouriteId,
                      type: _type
                    );
                    break;
                  }
                }
              }
              else if (_type == "saham") {
                for(WatchlistListModel watch in watchlistProvider.watchlistSaham!) {
                  if(watch.watchlistCompanyId == _watchlist.watchlistCompanyId) {
                    _watchlist = watch;
                    args = CompanyDetailArgs(
                      companyId: _watchlist.watchlistCompanyId,
                      companyName: _watchlist.watchlistCompanyName,
                      companyCode: _watchlist.watchlistCompanySymbol!,
                      companyFavourite: (_watchlist.watchlistFavouriteId > 0 ? true : false),
                      favouritesId: _watchlist.watchlistFavouriteId,
                      type: _type
                    );
                    break;
                  }
                }
              }
              else if (_type == "crypto") {
                for(WatchlistListModel watch in watchlistProvider.watchlistCrypto!) {
                  if(watch.watchlistCompanyId == _watchlist.watchlistCompanyId) {
                    _watchlist = watch;
                    args = CompanyDetailArgs(
                      companyId: _watchlist.watchlistCompanyId,
                      companyName: _watchlist.watchlistCompanyName,
                      companyCode: _watchlist.watchlistCompanySymbol!,
                      companyFavourite: (_watchlist.watchlistFavouriteId > 0 ? true : false),
                      favouritesId: _watchlist.watchlistFavouriteId,
                      type: _type
                    );
                    break;
                  }
                }
              }
              else if (_type == "gold") {
                for(WatchlistListModel watch in watchlistProvider.watchlistGold!) {
                  if(watch.watchlistCompanyId == _watchlist.watchlistCompanyId) {
                    _watchlist = watch;
                    break;
                  }
                }
              }
              
              // compute all the necessary info for summary
              _compute();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Visibility(
                    visible: (_watchlist.watchlistCompanyFCA ?? false),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      color: secondaryDark,
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Ionicons.warning,
                            color: secondaryLight,
                            size: 10,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            "This company is flagged with Full Call Auction",
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: _riskColor,
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: primaryDark,
                              border: Border(
                                bottom: BorderSide(
                                  color: primaryLight,
                                  width: 1.0,
                                  style: BorderStyle.solid,
                                )
                              )
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _watchlist.watchlistCompanyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            formatCurrency(_watchlist.watchlistCompanyNetAssetValue!),
                                            style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          Icon(
                                            (_priceDiff > 0 ? Ionicons.caret_up : Ionicons.caret_down),
                                            color: riskColor(
                                              value: _watchlist.watchlistCompanyNetAssetValue!,
                                              cost: _watchlist.watchlistCompanyPrevPrice!,
                                              riskFactor: _userInfo!.risk
                                            ),
                                          ),
                                          const SizedBox(width: 5,),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: riskColor(
                                                    value: _watchlist.watchlistCompanyNetAssetValue!,
                                                    cost: _watchlist.watchlistCompanyPrevPrice!,
                                                    riskFactor: _userInfo!.risk
                                                  ),
                                                  width: 2.0,
                                                  style: BorderStyle.solid,
                                                ),
                                              )
                                            ),
                                            child: Text(
                                              formatCurrency(_priceDiff),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 2,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        const Icon(
                                          Ionicons.time_outline,
                                          color: primaryLight,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10,),
                                        Text(
                                          Globals.dfddMMyyyy.formatDateWithNull(
                                            _watchlist.watchlistCompanyLastUpdate
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    WatchlistDetailSummaryBox(
                                      title: "AVG PRICE",
                                      text: (_totalCurrentShares > 0 ? formatCurrency(_totalCost / _totalCurrentShares) : "-"),
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "COST",
                                      text: formatCurrency(_totalCost)
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "VALUE",
                                      text: formatCurrency(_totalValue)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    WatchlistDetailSummaryBox(
                                      title: "BUY TIMES",
                                      text: "$_totalBuy"
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "BUY ${_watchlistArgs.shareName.toUpperCase()}",
                                      text: formatDecimal(
                                        (
                                          _watchlistArgs.isLot ?
                                          _totalSharesBuy / 100 :
                                          _totalSharesBuy
                                        ),
                                        decimal: 2
                                      )
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "BUY AMOUNT",
                                      text: formatCurrency(_totalBuyAmount)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    WatchlistDetailSummaryBox(
                                      title: "SELL TIMES",
                                      text: "$_totalSell"
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "SELL ${_watchlistArgs.shareName.toUpperCase()}",
                                      text: formatDecimal(
                                        (
                                          _watchlistArgs.isLot ?
                                          _totalSharesSell / 100 :
                                          _totalSharesSell
                                        ),
                                        decimal: 2
                                      )
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "SELL AMOUNT",
                                      text: formatCurrency(_totalSellAmount)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    WatchlistDetailSummaryBox(
                                      title: "CURRENT",
                                      text: formatDecimal(
                                        _totalCurrentShares,
                                        decimal: 2
                                      )
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "UNREALISED",
                                      text: formatCurrency(_totalUnrealisedGain)
                                    ),
                                    const SizedBox(width: 10,),
                                    WatchlistDetailSummaryBox(
                                      title: "REALISED",
                                      text: formatCurrency(_totalRealisedGain)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TransparentButton(
                          text: "Buy",
                          color: primaryDark,
                          borderColor: primaryLight,
                          icon: Ionicons.add,
                          onTap: (() {
                            Navigator.pushNamed(context, '/watchlist/detail/buy', arguments: _watchlistArgs);
                          })
                        ),
                        const SizedBox(width: 10,),
                        TransparentButton(
                          text: "Sell",
                          color: primaryDark,
                          borderColor: primaryLight,
                          icon: Ionicons.remove,
                          enabled: (_totalCurrentShares > 0),
                          onTap: (() {
                            WatchlistListArgs args = WatchlistListArgs(
                              type: _type,
                              watchList: _watchlist,
                              currentShare: _totalCurrentShares,
                              shareName: _watchlistArgs.shareName,
                              isLot: _watchlistArgs.isLot,
                            );
                            Navigator.pushNamed(context, '/watchlist/detail/sell', arguments: args);
                          })
                        ),
                        const SizedBox(width: 10,),
                        TransparentButton(
                          text: "Delete",
                          color: primaryDark,
                          borderColor: primaryLight,
                          icon: Ionicons.trash,
                          onTap: (() async {
                            await ShowMyDialog(
                              title: "Delete Watchlist",
                              text: "Are you sure to delete ${_watchlist.watchlistCompanyName}?",
                              confirmLabel: "Delete",
                              cancelLabel: "Cancel"
                            ).show(context).then((resp) async {
                              if(resp!) {
                                // delete the watchlist, all the success and error
                                // handling is moved to the function to ensure
                                // the context is mounted when we perform the
                                // delete on the watchlist.
                                await _deleteWatchlist();
                              }
                            },);
                          })
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: primaryDark,
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      )
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            "Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                          child: Text(
                            _watchlistArgs.shareName.toCapitalized(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          )
                        ),
                        const SizedBox(width: 10,),
                        const Expanded(
                          child: Text(
                            "Price",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          )
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _watchlist.watchlistDetail.length,
                      itemBuilder: (context, index) {
                        Color rColor = riskColor(
                          value: (_watchlist.watchlistDetail[index].watchlistDetailShare * (_watchlist.watchlistCompanyNetAssetValue ?? _watchlist.watchlistDetail[index].watchlistDetailShare)),
                          cost: (_watchlist.watchlistDetail[index].watchlistDetailShare * _watchlist.watchlistDetail[index].watchlistDetailPrice),
                          riskFactor: _userInfo!.risk
                        );
          
                        // check if the watchlist item date is more than company last update
                        // if so, then just make it black instead of calculate the risk color
                        // since we don't have the information for the date.
                        if (!_watchlist.watchlistDetail[index].watchlistDetailDate.toLocal().isSameOrBefore(
                          date: (_watchlist.watchlistCompanyLastUpdate ?? DateTime.now()).toLocal(),
                        )) {
                          rColor = Colors.black;
                        }
              
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: <Widget>[
                              SlideButton(
                                icon: Ionicons.pencil,
                                iconColor: accentColor,
                                onTap: () {
                                  Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: args);
                                },
                              ),
                              SlideButton(
                                icon: Ionicons.trash,
                                iconColor: secondaryColor,
                                onTap: () async {
                                  await ShowMyDialog(
                                    title: "Delete Detail",
                                    text: "Are you sure to delete this detail?\nDate: ${Globals.dfddMMyyyy.formatLocal(_watchlist.watchlistDetail[index].watchlistDetailDate)}\nShares: ${formatDecimal(_watchlist.watchlistDetail[index].watchlistDetailShare)}\nPrice: ${formatCurrency(_watchlist.watchlistDetail[index].watchlistDetailPrice)}",
                                    confirmLabel: "Delete",
                                    cancelLabel: "Cancel"
                                  ).show(context).then((resp) async {
                                    if(resp!) {
                                      await _deleteDetail(_watchlist.watchlistDetail[index].watchlistDetailId).then((resp) {
                                        if(resp) {
                                          Log.success(message: "🧹 Delete ${_watchlist.watchlistDetail[index].watchlistDetailId}");
                                        }
                                        else {
                                          Log.error(message: "🧹 Unable to delete ${_watchlist.watchlistDetail[index].watchlistDetailId}");
                                        }
                                      }).onError((error, stackTrace) {
                                        Log.error(
                                          message: 'Error deleting watchlist detail',
                                          error: error,
                                          stackTrace: stackTrace,
                                        );
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
                              Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: args);
                            }),
                            child: IntrinsicHeight(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _listColor(_watchlist.watchlistDetail[index].watchlistDetailShare),
                                  border: const Border(
                                    bottom: BorderSide(
                                      color: primaryLight,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    )
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      color: (_watchlist.watchlistDetail[index].watchlistDetailShare > 0 ? rColor : extendedDark),
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(5, 12, 10, 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                Globals.dfddMMyyyy.formatLocal(_watchlist.watchlistDetail[index].watchlistDetailDate),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                              child: Text(
                                                formatCurrency(
                                                  _watchlistArgs.isLot ?
                                                  _watchlist.watchlistDetail[index].watchlistDetailShare / 100 :
                                                  _watchlist.watchlistDetail[index].watchlistDetailShare
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                              child: Text(
                                                formatCurrency(_watchlist.watchlistDetail[index].watchlistDetailPrice),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.right,
                                              )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _listColor(double share) {
    return (share < 0 ? extendedColor : Colors.transparent);
  }

  Future<bool> _deleteDetail(int watchlistDetailID) async {
    bool ret = false;

    // show loading screen
    LoadingScreen.instance().show(context: context);

    // call API to delete the watchlist detail
    await _watchlistApi.deleteDetail(id: watchlistDetailID).then((resp) async {
      if(resp) {
        // first create the new watchlist for this
        List<WatchlistListModel> newWatchlist = [];
        List<WatchlistDetailListModel> newWatchlistDetail = [];

        // loop thru the current detail
        for (WatchlistDetailListModel detail in _watchlist.watchlistDetail) {
          // check if the ID is the same? If not then add this to the new list
          if(detail.watchlistDetailId != watchlistDetailID) {
            newWatchlistDetail.add(detail);
          }
        }

        // create a new Watchlist Model for this data
        WatchlistListModel newWatchlistModel = WatchlistListModel(
          watchlistId: _watchlist.watchlistId,
          watchlistCompanyId: _watchlist.watchlistCompanyId,
          watchlistCompanyName: _watchlist.watchlistCompanyName,
          watchlistCompanySymbol: _watchlist.watchlistCompanySymbol,
          watchlistDetail: newWatchlistDetail,
          watchlistCompanyNetAssetValue: _watchlist.watchlistCompanyNetAssetValue,
          watchlistCompanyPrevPrice: _watchlist.watchlistCompanyPrevPrice,
          watchlistCompanyLastUpdate: _watchlist.watchlistCompanyLastUpdate,
          watchlistFavouriteId: _watchlist.watchlistFavouriteId,
          watchlistCompanyFCA: _watchlist.watchlistCompanyFCA,
        );

        List<WatchlistListModel> currWatchlist = WatchlistSharedPreferences.getWatchlist(type: _type);
        
        // loop thru the current watchlist
        for (WatchlistListModel watch in currWatchlist) {
          if(_watchlist.watchlistId == watch.watchlistId) {
            // change this to the updated one
            newWatchlist.add(newWatchlistModel);
          }
          else {
            newWatchlist.add(watch);
          }
        }

        // once we finished generate the updated watchlist, update the shared preferences
        // and the provider
        await WatchlistSharedPreferences.setWatchlist(
          type: _type,
          watchlistData: newWatchlist
        );

        if (mounted) {
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
            type: _type,
            watchlistData: newWatchlist
          );
        }
      }

      ret = resp;
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove loading screen
      LoadingScreen.instance().hide();
    });

    return ret;
  }

  Future<void> _deleteWatchlist() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // call API server to delete the watchlist
    await _watchlistApi.delete(
      watchlistId: _watchlist.watchlistId
    ).then((resp) async {
      if(resp) {
        Log.success(message: "🗑️ Delete watchlist ${_watchlist.watchlistCompanyName}");
        
        // delete the current watchlist
        List<WatchlistListModel> newWatchlist = [];
        List<WatchlistListModel> currentWatchlist = WatchlistSharedPreferences.getWatchlist(type: _type);
        for (WatchlistListModel watch in currentWatchlist) {
          if(watch.watchlistId != _watchlist.watchlistId) {
            newWatchlist.add(watch);
          }
        }

        // update shared preferences and provdier
        await WatchlistSharedPreferences.setWatchlist(
          type: _type,
          watchlistData: newWatchlist
        );

        // ensure it's already mounted
        if (mounted) {
          // update provider so the other page will refresh
          Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(
            type: _type,
            watchlistData: newWatchlist
          );
          
          // navigate to the previous page
          Navigator.pop(context); 
        }
      }
      
      if (resp) {
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
      }
    }).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    });
  }

  void _compute() {
    WatchlistComputationResult computeResult = detailWatchlistComputation(watchlist: _watchlist, riskFactor: _userInfo!.risk);
    
    // compute all necessary data for the summary, such as cost, gain
    _totalCost = computeResult.totalCost;
    _totalUnrealisedGain = computeResult.totalUnrealisedGain;
    _totalRealisedGain = computeResult.totalRealisedGain;
    _totalCurrentShares = computeResult.totalCurrentShares;
    _totalSharesBuy = computeResult.totalSharesBuy;
    _totalSharesSell = computeResult.totalSharesSell;
    _totalBuy = computeResult.totalBuy;
    _totalSell = computeResult.totalSell;
    _totalBuyAmount = computeResult.totalBuyAmount;
    _totalSellAmount = computeResult.totalSellAmount;
    _priceDiff = computeResult.priceDiff;
    _riskColor = computeResult.riskColor;
    _totalValue = computeResult.totalValue;
  }
}