import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_detail_edit_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/utils/prefs/shared_watchlist.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/widgets/watchlist_detail_summary_box.dart';
import 'package:provider/provider.dart';

class WatchlistListPage extends StatefulWidget {
  final Object? watchlistArgs;
  const WatchlistListPage({ Key? key, required this.watchlistArgs }) : super(key: key);

  @override
  WatchlistListPageState createState() => WatchlistListPageState();
}

class WatchlistListPageState extends State<WatchlistListPage> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final WatchlistAPI _watchlistApi = WatchlistAPI();
  final GlobalKey _scaffold = GlobalKey();

  late WatchlistListArgs _watchlistArgs;
  late String _type;
  late WatchlistListModel _watchlist;
  late UserLoginInfoModel? _userInfo;
  late CompanyDetailArgs? args;

  int _totalBuy = 0;
  int _totalSell = 0;
  double _priceDiff = 0;
  double _totalCost = 0;
  double _totalGain = 0;
  double _totalSellAmount = 0;
  double _totalValue = 0;
  double _totalCurrentShares = 0;
  double _totalSharesSell = 0;
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
    super.dispose();
    _scrollController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        return false;
      }),
      child: Scaffold(
        key: _scaffold,
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
                  debugPrint("Show company");
                  Navigator.pushNamed(context, '/company/detail/$_type', arguments: args);
                }
              }),
              icon: const Icon(
                Ionicons.business_outline
              ),
            )
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
        body: Consumer<WatchlistProvider>(
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
              children: [
                Container(
                  color: _riskColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(width: 10,),
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
                              const SizedBox(height: 10,),
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
                                          color: riskColor(_watchlist.watchlistCompanyNetAssetValue!, _watchlist.watchlistCompanyPrevPrice!, _userInfo!.risk),
                                        ),
                                        const SizedBox(width: 5,),
                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: riskColor(_watchlist.watchlistCompanyNetAssetValue!, _watchlist.watchlistCompanyPrevPrice!, _userInfo!.risk),
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
                                  const SizedBox(height: 10,),
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
                                        (_watchlist.watchlistCompanyLastUpdate == null ? "-" : _df.format(_watchlist.watchlistCompanyLastUpdate!.toLocal()))
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 10,),
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
                              const SizedBox(height: 10,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  WatchlistDetailSummaryBox(
                                    title: "BUY LOTS",
                                    text: "$_totalBuy lots"
                                  ),
                                  const SizedBox(width: 10,),
                                  WatchlistDetailSummaryBox(
                                    title: "SHARES",
                                    text: formatDecimal(_totalCurrentShares, 2)
                                  ),
                                  const SizedBox(width: 10,),
                                  WatchlistDetailSummaryBox(
                                    title: "GAIN",
                                    text: formatCurrency(_totalGain)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  WatchlistDetailSummaryBox(
                                    title: "SELL LOTS",
                                    text: "$_totalSell lots"
                                  ),
                                  const SizedBox(width: 10,),
                                  WatchlistDetailSummaryBox(
                                    title: "SHARES",
                                    text: formatDecimal(_totalSharesSell, 2)
                                  ),
                                  const SizedBox(width: 10,),
                                  WatchlistDetailSummaryBox(
                                    title: "SELL AMOUNT",
                                    text: formatCurrency(_totalSellAmount)
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
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
                        icon: Ionicons.add,
                        callback: (() {
                          WatchlistListArgs args = WatchlistListArgs(type: _type, watchList: _watchlist);
                          Navigator.pushNamed(context, '/watchlist/detail/buy', arguments: args);
                        })
                      ),
                      const SizedBox(width: 10,),
                      TransparentButton(
                        text: "Sell",
                        icon: Ionicons.remove,
                        callback: (() {
                          WatchlistListArgs args = WatchlistListArgs(type: _type, watchList: _watchlist);
                          Navigator.pushNamed(context, '/watchlist/detail/sell', arguments: args);
                        })
                      ),
                      const SizedBox(width: 10,),
                      TransparentButton(
                        text: "Delete",
                        icon: Ionicons.trash,
                        callback: (() async {
                          await ShowMyDialog(
                            title: "Delete Watchlist",
                            text: "Are you sure to delete ${_watchlist.watchlistCompanyName}?",
                            confirmLabel: "Delete",
                            cancelLabel: "Cancel"
                          ).show(context).then((resp) async {
                            if(resp!) {
                              // show the loader
                              showLoaderDialog(context);
                              await _deleteWatchlist().then((resp) {
                                if(resp) {
                                  debugPrint("??????? Delete watchlist ${_watchlist.watchlistCompanyName}");
                                  // navigate to the previous page
                                  Navigator.pop(context); 
                                }
                              }).onError((error, stackTrace) {
                                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                              }).whenComplete(() {
                                // remove the loader
                                Navigator.pop(context);
                              });
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
                    children: const <Widget>[
                      Expanded(
                        child: Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          "Shares",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        )
                      ),
                      SizedBox(width: 10,),
                      Expanded(
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
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: List<Widget>.generate(_watchlist.watchlistDetail.length, (index) {
                      WatchlistDetailEditArgs args = WatchlistDetailEditArgs(type: _type, index: index, watchlist: _watchlist);
    
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: <Widget>[
                            SlidableAction(
                              onPressed: ((context) {
                                Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: args);
                              }),
                              icon: Ionicons.pencil,
                              backgroundColor: primaryColor,
                              foregroundColor: accentColor,
                            ),
                            SlidableAction(
                              onPressed: ((context) async {
                                await ShowMyDialog(
                                  title: "Delete Detail",
                                  text: "Are you sure to delete this detail?\nDate: ${_df.format(_watchlist.watchlistDetail[index].watchlistDetailDate)}\nShares: ${formatDecimal(_watchlist.watchlistDetail[index].watchlistDetailShare)}\nPrice: ${formatCurrency(_watchlist.watchlistDetail[index].watchlistDetailPrice)}",
                                  confirmLabel: "Delete",
                                  cancelLabel: "Cancel"
                                ).show(context).then((resp) async {
                                  if(resp!) {
                                    await _deleteDetail(_watchlist.watchlistDetail[index].watchlistDetailId).then((resp) {
                                      if(resp) {
                                        debugPrint("???? Delete ${_watchlist.watchlistDetail[index].watchlistDetailId}");
                                      }
                                      else {
                                        debugPrint("???? Unable to delete ${_watchlist.watchlistDetail[index].watchlistDetailId}");
                                      }
                                    }).onError((error, stackTrace) {
                                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                                    });
                                  }
                                });
                              }),
                              icon: Ionicons.trash,
                              backgroundColor: primaryColor,
                              foregroundColor: secondaryColor,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onDoubleTap: (() {
                            Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: args);
                          }),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                            decoration: BoxDecoration(
                              color: _listColor(_watchlist.watchlistDetail[index].watchlistDetailShare),
                              border: const Border(
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
                                Expanded(
                                  child: Text(
                                    _df.format(_watchlist.watchlistDetail[index].watchlistDetailDate.toLocal()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    formatCurrency(_watchlist.watchlistDetail[index].watchlistDetailShare),
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
                      );
                    }),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Color _listColor(double share) {
    return (share < 0 ? extendedColor : Colors.transparent);
  }

  Future<bool> _deleteDetail(int watchlistDetailID) async {
    bool ret = false;

    showLoaderDialog(context);
    await _watchlistApi.deleteDetail(watchlistDetailID).then((resp) async {
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
        );

        List<WatchlistListModel> currWatchlist = WatchlistSharedPreferences.getWatchlist(_type);
        
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
        await WatchlistSharedPreferences.setWatchlist(_type, newWatchlist);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchlist);
      }

      ret = resp;
    // await Future.delayed(Duration(milliseconds: 10)).then((_) {
    //   _ret = true;
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    }).whenComplete(() {
      // remove the loader
      Navigator.pop(context);
    });

    return ret;
  }

  Future<bool> _deleteWatchlist() async {
    bool ret = false;
    await _watchlistApi.delete(_watchlist.watchlistId).then((resp) async {
      if(resp) {
        // delete the current watchlist
        List<WatchlistListModel> newWatchlist = [];
        List<WatchlistListModel> currentWatchlist = WatchlistSharedPreferences.getWatchlist(_type);
        for (WatchlistListModel watch in currentWatchlist) {
          if(watch.watchlistId != _watchlist.watchlistId) {
            newWatchlist.add(watch);
          }
        }

        // update shared preferences and provdier
        await WatchlistSharedPreferences.setWatchlist(_type, newWatchlist);
        if (!mounted) return;
        Provider.of<WatchlistProvider>(context, listen: false).setWatchlist(_type, newWatchlist);
      }
      ret = resp;
    });
    return ret;
  }

  void _compute() {
    // compute all necessary data for the summary, such as cost, gain
    _totalCost = 0;
    _totalGain = 0;
    _totalCurrentShares = 0;
    _totalSharesSell = 0;
    _totalBuy = 0;
    _totalSell = 0;
    _totalSellAmount = 0;

    // compute the price diff
    _priceDiff = (_watchlist.watchlistCompanyNetAssetValue! - _watchlist.watchlistCompanyPrevPrice!) ;

    // for the calculation of the sell share's to avoid any average cost problem
    // we need to see how much is the average cost for each share that we buy
    double totalShareBuy = 0;
    double totalCostBuy = 0;
    double totalCostSell = 0;
    double averageBuyPrice = 0;
    for (WatchlistDetailListModel detail in _watchlist.watchlistDetail) {
      if (detail.watchlistDetailShare > 0) {
        totalShareBuy += detail.watchlistDetailShare;
        totalCostBuy += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        _totalBuy++;
      }
      else {
        _totalSharesSell += detail.watchlistDetailShare;
        _totalSellAmount += (detail.watchlistDetailShare * detail.watchlistDetailPrice);
        _totalSell++;
      }
    }
    // get what is the average buy price that we have
    if (totalShareBuy > 0 && totalCostBuy > 0) {
      averageBuyPrice = totalCostBuy / totalShareBuy;
    }

    // total sell is negative, make it a positive
    _totalSharesSell *= -1;
    _totalSellAmount *= -1;

    // calculate the total cost sell, this is should be the total shares we sell times the averageBuyPrice
    totalCostSell = _totalSharesSell * averageBuyPrice;

    // set the result
    // total share should be buy subtract by sell
    _totalCurrentShares = totalShareBuy - _totalSharesSell;
    _totalGain = (_watchlist.watchlistCompanyNetAssetValue! * (totalShareBuy - _totalSharesSell)) - (averageBuyPrice * (totalShareBuy - _totalSharesSell));
    _totalCost = totalCostBuy - totalCostSell;
    _totalValue = _totalCurrentShares * _watchlist.watchlistCompanyNetAssetValue!;
    _riskColor = riskColor(_totalValue, _totalCost, _userInfo!.risk);
  }
}