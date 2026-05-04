import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_wealth/utils/icon/my_ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class WatchlistListData {
  final int id;
  final double share;
  late double shareLeft;
  late double price;
  final DateTime date;
  late bool status;
  late double pl;
  late double plPercentage;

  WatchlistListData({
      required this.id,
      required this.share,
      required this.shareLeft,
      required this.price,
      required this.date,
      required this.status,
  });
}

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
  late List<WatchlistListData> _watchlistDetailData;
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
    _watchlist = _watchlistArgs.watchlist;
    
    // generate the watchlist detail data
    _watchlistDetailData = [];
    _generateWatchlistData();

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
            icon: Icon(
              MyIonicons(MyIoniconsData.arrow_back).data
            ),
            onPressed: (() {
              Navigator.pop(context);
            }),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, '/company/detail/$_type', arguments: args);
              }),
              icon: Icon(
                MyIonicons(MyIoniconsData.business_outline).data
              ),
            ),
            IconButton(
              onPressed: (() {
                Navigator.pushNamed(context, '/watchlist/performance', arguments: _watchlistArgs);
              }),
              icon: Icon(
                MyIonicons(MyIoniconsData.pulse_outline).data
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
              _watchlist = watchlistProvider.watchlistData![_type]!.firstWhere((element) => element.watchlistCompanyId == _watchlist.watchlistCompanyId);
              _generateWatchlistData();

              // create the argument to get company detail
              args = CompanyDetailArgs(
                companyId: _watchlist.watchlistCompanyId,
                companyName: _watchlist.watchlistCompanyName,
                companyCode: _watchlist.watchlistCompanySymbol!,
                companyFavourite: (_watchlist.watchlistFavouriteId > 0 ? true : false),
                favouritesId: _watchlist.watchlistFavouriteId,
                type: _type
              );
              
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            MyIonicons(MyIoniconsData.warning).data,
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
                                            (_priceDiff > 0 ? MyIonicons(MyIoniconsData.caret_up).data : MyIonicons(MyIoniconsData.caret_down).data),
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
                                        Icon(
                                          MyIonicons(MyIoniconsData.time_outline).data,
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
                          icon: MyIonicons(MyIoniconsData.add).data,
                          onTap: (() {
                            Navigator.pushNamed(context, '/watchlist/detail/buy', arguments: _watchlistArgs);
                          })
                        ),
                        const SizedBox(width: 10,),
                        TransparentButton(
                          text: "Sell",
                          color: primaryDark,
                          borderColor: primaryLight,
                          icon: MyIonicons(MyIoniconsData.remove).data,
                          enabled: (_totalCurrentShares > 0),
                          onTap: (() {
                            WatchlistListArgs args = WatchlistListArgs(
                              type: _type,
                              watchlist: _watchlist,
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
                          icon: MyIonicons(MyIoniconsData.trash).data,
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
                      itemCount: _watchlistDetailData.length,
                      itemBuilder: (context, index) {
                        bool partiallyRealized = ((_watchlistDetailData[index].shareLeft > 0) && (_watchlistDetailData[index].share != _watchlistDetailData[index].shareLeft));

                        Color rColor = riskColor(
                          value: (_watchlistDetailData[index].share * (_watchlist.watchlistCompanyNetAssetValue ?? _watchlistDetailData[index].share)),
                          cost: (_watchlistDetailData[index].share * _watchlistDetailData[index].price),
                          riskFactor: _userInfo!.risk
                        );
                        Color currentPLColor = Colors.white;
                        Color currentTextColor = textPrimary;

                        double currentTotalBuySell = _watchlistDetailData[index].shareLeft.abs() * _watchlistDetailData[index].price;

                        double currentShare = _watchlistDetailData[index].share;
          
                        // check if the watchlist item date is more than company last update
                        // if so, then just make it black instead of calculate the risk color
                        // since we don't have the information for the date.
                        if (!_watchlistDetailData[index].date.toLocal().isSameOrBefore(
                          date: (_watchlist.watchlistCompanyLastUpdate ?? DateTime.now()).toLocal(),
                        )) {
                          rColor = Colors.black;
                        }
                        else if (_watchlistDetailData[index].share > 0 && _watchlistDetailData[index].status == false) {
                          // This item has been realized, so we don't calculate risk
                          rColor = primaryLight;
                          currentPLColor = primaryLight.lighten(amount: 0.2);
                          currentTextColor = primaryLight.lighten(amount: 0.2);
                        }
                        else {
                          // check if currentPL is + or -
                          if (_watchlistDetailData[index].pl > 0) {
                            currentPLColor = green50;
                          }
                          else if (_watchlistDetailData[index].pl < 0) {
                            currentPLColor = red40;
                          }
                        }

                        // check if this is partialy realized
                        if (partiallyRealized) {
                          currentTextColor = accentColor;
                          currentShare = _watchlistDetailData[index].shareLeft;
                        }

                        WatchlistDetailEditArgs editArg = WatchlistDetailEditArgs(
                          type: _type,
                          watchlist: _watchlist,
                          index: index,
                          isLot: _watchlistArgs.isLot,
                          shareName: _watchlistArgs.shareName,
                        ); 
              
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: <Widget>[
                              SlideButton(
                                icon: MyIonicons(MyIoniconsData.pencil).data,
                                iconColor: accentColor,
                                onTap: () {
                                  Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: editArg);
                                },
                              ),
                              SlideButton(
                                icon: MyIonicons(MyIoniconsData.trash).data,
                                iconColor: secondaryColor,
                                onTap: () async {
                                  await ShowMyDialog(
                                    title: "Delete Detail",
                                    text: "Are you sure to delete this detail?\nDate: ${Globals.dfddMMyyyy.formatLocal(_watchlistDetailData[index].date)}\nShares: ${formatDecimal(currentShare)}\nPrice: ${formatCurrency(_watchlistDetailData[index].price)}",
                                    confirmLabel: "Delete",
                                    cancelLabel: "Cancel"
                                  ).show(context).then((resp) async {
                                    if(resp!) {
                                      await _deleteDetail(_watchlistDetailData[index].id).then((resp) {
                                        if(resp) {
                                          Log.success(message: "🧹 Delete ${_watchlistDetailData[index].id}");
                                        }
                                        else {
                                          Log.error(message: "🧹 Unable to delete ${_watchlistDetailData[index].id}");
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
                                  color: _listColor(_watchlistDetailData[index].share),
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
                                      color: (_watchlistDetailData[index].share > 0 ? rColor : extendedDark),
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                Globals.dfddMMyyyy.formatLocal(_watchlistDetailData[index].date),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: currentTextColor,
                                                ),
                                              )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    formatCurrency(
                                                      _watchlistArgs.isLot ?
                                                      currentShare / 100 :
                                                      currentShare
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: currentTextColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "${formatCurrencyWithNull(_watchlistDetailData[index].pl, checkThousand: true)} (${formatDecimalWithNull(_watchlistDetailData[index].plPercentage, times: 100, decimal: 2)}%)",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: currentPLColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              )
                                            ),
                                            const SizedBox(width: 10,),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    formatCurrency(_watchlistDetailData[index].price),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: currentTextColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.right,
                                                  ),
                                                  Text(
                                                    formatCurrencyWithNull(currentTotalBuySell, checkThousand: true),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: currentTextColor,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
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
            data: newWatchlist
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
            data: newWatchlist
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

  void _generateWatchlistData() {
    // clear the watchlist detail data
    _watchlistDetailData.clear();

    // loop thru the watchlist detail and put into watchlist detail data
    _watchlistDetailData = _watchlist.watchlistDetail.map((detail) {
      return WatchlistListData(
        id: detail.watchlistDetailId,
        share: detail.watchlistDetailShare,
        shareLeft: detail.watchlistDetailShare,
        price: detail.watchlistDetailPrice,
        date: detail.watchlistDetailDate,
        status: (detail.watchlistDetailShare > 0 ? true : false),
      );
    }).toList();

    // sort the watchlist detail data by date in ascending
    _watchlistDetailData.sort((a, b) => a.date.compareTo(b.date));

    // calculate the PL for each watchlist detail data by loop and calculate
    double totalBuy = 0;
    double totalShares = 0;
    double currentPrice;
    double buyPrice;
    double avgPrice;
    double sellShareLeft;
    double currentShareLeftPrice;
    double buyShareLeftPrice;

    // loop the watchlist detail data
    for (int i = 0; i < _watchlistDetailData.length; i++) {
      // check if this is buy or sell
      // this is indicated by the share whether the < 0 (sell), or > 0 (buy)
      if (_watchlistDetailData[i].share > 0) {
        // the current and buy price for this item
        currentPrice = (_watchlist.watchlistCompanyNetAssetValue ?? 0) * _watchlistDetailData[i].share;
        buyPrice = _watchlistDetailData[i].price * _watchlistDetailData[i].share; 

        // add the total buy
        totalBuy += buyPrice;
      }
      else {
        // this is sell, for this we need to tell the realized gain loss for this sell.
        // we can get the average price by divide the total shares and total buy
        avgPrice = totalBuy / totalShares;

        // then calculate the total sell
        buyPrice = _watchlistDetailData[i].share.abs() * avgPrice;
        currentPrice = _watchlistDetailData[i].share.abs() * _watchlistDetailData[i].price;

        // since we have sell, we need to remove the status of the previous buy to false
        // so we don't need to calculate or showed the PL on the watchlist again
        // as this will reflect poortly on the way it represent the unrealized gain
        sellShareLeft = _watchlistDetailData[i].share.abs();
        for (int j = 0; j < i && sellShareLeft > 0; j++) {
          if (_watchlistDetailData[j].share > 0 && _watchlistDetailData[j].status) {
            // check if current share is less than sellShareLeft
            if (sellShareLeft >= _watchlistDetailData[j].shareLeft) {
              // this means we can remove all the share left for this buy
              sellShareLeft -= _watchlistDetailData[j].shareLeft;
              _watchlistDetailData[j].shareLeft = 0;
              _watchlistDetailData[j].status = false;

              // recalculate PL based on the average price instead or current price
              _watchlistDetailData[j].pl = 0;
              _watchlistDetailData[j].plPercentage = 0;
            }
            else {
              // this means we can only remove part of the share left for this buy
              _watchlistDetailData[j].shareLeft -= sellShareLeft;
              sellShareLeft = 0;

              // recalculate the PL based on the remaining share left
              currentShareLeftPrice = _watchlistDetailData[j].shareLeft * (_watchlist.watchlistCompanyNetAssetValue ?? 0);
              buyShareLeftPrice = _watchlistDetailData[j].shareLeft * _watchlistDetailData[j].price;
              _watchlistDetailData[j].pl = currentShareLeftPrice - buyShareLeftPrice;
              _watchlistDetailData[j].plPercentage = (currentShareLeftPrice - buyShareLeftPrice) / buyShareLeftPrice;

              // change the price to average price
              _watchlistDetailData[j].price = avgPrice;
            }
          }
        }
      }

      // calculate the PL for this item
      _watchlistDetailData[i].pl = currentPrice - buyPrice;
      _watchlistDetailData[i].plPercentage = (currentPrice - buyPrice) / buyPrice;

      // add the total shares
      totalShares += _watchlistDetailData[i].share;
    }

    // reverse the watchlist detail data so the latest will be on top
    _watchlistDetailData = _watchlistDetailData.reversed.toList();
  }
}