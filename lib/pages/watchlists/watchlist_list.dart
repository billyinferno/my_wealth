import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/user_login.dart';
import 'package:my_wealth/model/watchlist_detail_list_model.dart';
import 'package:my_wealth/model/watchlist_list_model.dart';
import 'package:my_wealth/provider/watchlist_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/watchlist_detail_edit_args.dart';
import 'package:my_wealth/utils/dialog/show_my_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/function/risk_color.dart';
import 'package:my_wealth/utils/prefs/shared_user.dart';
import 'package:my_wealth/widgets/transparent_button.dart';
import 'package:my_wealth/utils/extensions/string.dart';
import 'package:my_wealth/widgets/watchlist_detail_summary_box.dart';
import 'package:provider/provider.dart';

class WatchlistListPage extends StatefulWidget {
  final Object? watchlist;
  const WatchlistListPage({ Key? key, required this.watchlist }) : super(key: key);

  @override
  _WatchlistListPageState createState() => _WatchlistListPageState();
}

class _WatchlistListPageState extends State<WatchlistListPage> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _df = DateFormat('dd/MM/yyyy');

  late WatchlistListModel _watchlist;
  late UserLoginInfoModel? _userInfo;

  double _totalCost = 0;
  double _totalGain = 0;
  double _totalValue = 0;
  double _totalShares = 0;
  Color _riskColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _watchlist = widget.watchlist as WatchlistListModel;
    _userInfo = UserSharedPreferences.getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back
          ),
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
        title: Center(
          child: Text(
            _watchlist.watchlistCompanyName.toTitleCase(),
            style: const TextStyle(
              color: secondaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: Consumer<WatchlistProvider>(
        builder: ((context, watchlistProvider, child) {
          // get the actual data of this watchlist from provider.
          // so when we refresh the provider, the watchlist will be updated also.
          for(WatchlistListModel _watch in watchlistProvider.watchlist!) {
            if(_watch.watchlistCompanyId == _watchlist.watchlistCompanyId) {
              _watchlist = _watch;
              break;
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                WatchlistDetailSummaryBox(
                                  title: "PRICE",
                                  text: formatCurrency(_watchlist.watchlistCompanyNetAssetValue!)
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
                                  title: "LOTS",
                                  text: _watchlist.watchlistDetail.length.toString() + " lots"
                                ),
                                const SizedBox(width: 10,),
                                WatchlistDetailSummaryBox(
                                  title: "SHARES",
                                  text: formatDecimal(_totalShares, 2)
                                ),
                                const SizedBox(width: 10,),
                                WatchlistDetailSummaryBox(
                                  title: "GAIN",
                                  text: formatCurrency(_totalGain)
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
                      text: "Add Detail",
                      icon: Ionicons.add,
                      callback: (() {
                        Navigator.pushNamed(context, '/watchlist/detail/create', arguments: _watchlist);
                      })
                    ),
                    const SizedBox(width: 10,),
                    TransparentButton(
                      text: "Delete Watchlist",
                      icon: Ionicons.trash,
                      callback: (() async {
                        await ShowMyDialog(
                          title: "Delete Watchlist",
                          text: "Are you sure to delete " + _watchlist.watchlistCompanyName.toTitleCase() + "?",
                          confirmLabel: "Delete",
                          cancelLabel: "Cancel"
                        ).show(context).then((resp) {
                          if(resp!) {
                            //TODO: to delete the watchlist
                            debugPrint("Delete this watchlist");
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
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: <Widget>[
                          SlidableAction(
                            onPressed: ((context) {
                              WatchlistDetailEditArgs _args = WatchlistDetailEditArgs(index: index, watchlist: _watchlist);
                              Navigator.pushNamed(context, '/watchlist/detail/edit', arguments: _args);
                            }),
                            icon: Ionicons.pencil,
                            backgroundColor: primaryColor,
                            foregroundColor: accentColor,
                          ),
                          SlidableAction(
                            onPressed: ((context) async {
                              //TODO: add confirmation dialog if user want to delete or not?
                              await ShowMyDialog(
                                title: "Delete Detail",
                                text: "Are you sure to delete this detail?\n"
                                  "Date: " + _df.format(_watchlist.watchlistDetail[index].watchlistDetailDate) + "\n" +
                                  "Shares: " + formatDecimal(_watchlist.watchlistDetail[index].watchlistDetailShare) + "\n" +
                                  "Price: " + formatCurrency(_watchlist.watchlistDetail[index].watchlistDetailPrice),
                                confirmLabel: "Delete",
                                cancelLabel: "Cancel"
                              ).show(context).then((resp) {
                                if(resp!) {
                                  debugPrint("Delete " + _watchlist.watchlistDetail[index].watchlistDetailId.toString());
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
                          //TODO: go to edit page
                          debugPrint("Edit " + _watchlist.watchlistDetail[index].watchlistDetailId.toString());
                        }),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                          decoration: const BoxDecoration(
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
    );
  }

  void _compute() {
    // compute all necessary data for the summary, such as cost, gain
    _totalCost = 0;
    _totalGain = 0;
    _totalShares = 0;

    // loop thru all the detail to compute
    for(WatchlistDetailListModel _detail in _watchlist.watchlistDetail) {
      _totalCost += _detail.watchlistDetailPrice * _detail.watchlistDetailShare;
      _totalGain += ((_watchlist.watchlistCompanyNetAssetValue! - _detail.watchlistDetailPrice) * _detail.watchlistDetailShare);
      _totalShares += _detail.watchlistDetailShare;
    }
    _totalValue = _totalShares * _watchlist.watchlistCompanyNetAssetValue!;
    _riskColor = riskColor(_totalValue, _totalCost, _userInfo!.risk);
  }
}