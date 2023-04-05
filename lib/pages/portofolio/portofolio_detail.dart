import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/portofolio/portofolio_detail_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/widgets/product_list_item.dart';

class PortofolioDetailPage extends StatefulWidget {
  final Object? args;
  const PortofolioDetailPage({Key? key, required this.args}) : super(key: key);

  @override
  State<PortofolioDetailPage> createState() => _PortofolioDetailPageState();
}

class _PortofolioDetailPageState extends State<PortofolioDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final PortofolioAPI _portofolioAPI = PortofolioAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  
  late PortofolioListArgs _args;
  
  late List<PortofolioDetailModel> _portofolioList;
  late List<PortofolioDetailModel> _portofolioFiltered;

  Color trendColor = Colors.white;
  Color realisedColor = Colors.white;
  IconData trendIcon = Ionicons.remove;
  bool _isLoading = true;
  double _portofolioTotalValue = 0;

  String _sortType = "code";
  final Map<String, String> _sortMap = {
    "code": "Code/Name",
    "total": "Total Value",
    "left": "Share Left",
    "realizedpl": "Realized P/L",
    "unrealizedpl": "Unrealizd P/L",
    "oneday": "Daily Gain (%)",
  };
  final List<String> _sortList = ["code", "total", "left", "realizedpl", "unrealizedpl", "oneday"];
  bool _sortAscending = true;

  @override
  void initState() {
    // init list
    _portofolioList = [];
    _portofolioFiltered = [];

    // convert the arguments into portofilio list args
    _args = widget.args as PortofolioListArgs;

    // check unrealised and realised to determine the trend color and icon
    if((_args.unrealised ?? 0) > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.trending_up;
    }
    else if((_args.unrealised ?? 0) < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.trending_down;
    }

    if((_args.realised ?? 0) > 0) {
      realisedColor = Colors.green;
    }
    else if((_args.unrealised ?? 0) < 0) {
      realisedColor = secondaryColor;
    }


    Future.microtask(() async {
      showLoaderDialog(context);

      await _portofolioAPI.getPortofolioDetail(_args.type, _args.subType!).then((resp) {
        _portofolioList = resp;
        
        // generate the _barChartData based on response
        _portofolioTotalValue = 0;
        for (PortofolioDetailModel porto in resp) {
          _portofolioTotalValue += porto.watchlistSubTotalValue;
        }

        // call filter
        _filterList();
      }).whenComplete(() {
        // remove the loader
        Navigator.pop(context);
        
        // set the is loading into false
        setState(() {
          _isLoading = false;
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if still loading then just throw a blank container
    if (_isLoading) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ((() {
            // return back to the previous page
            Navigator.pop(context);
          })),
          icon: const Icon(
            Ionicons.arrow_back,
          )
        ),
        title: Center(
          child: Text(
            _args.title,
            style: const TextStyle(
              color: secondaryColor,
            ),
          )
        ),
        actions: <Widget>[
          IconButton(
            onPressed: (() {
              // show the modal dialog for what to filter
              // code/name, total investment, share left, realized pl, unrealized pl, one day
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                builder: (context) {
                  return SizedBox(
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount: _sortList.length,
                            itemBuilder: ((context, index) {
                              return InkWell(
                                onTap: (() {
                                  setState(() {
                                    _sortType = _sortList[index];
                                    _filterList();
                                  });
                                  // dismiss the bottom sheet
                                  Navigator.pop(context);
                                }),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: primaryLight,
                                        width: 1.0,
                                        style: BorderStyle.solid,
                                      )
                                    )
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                    child: Text(
                                      (_sortMap[_sortList[index]] ?? _sortList[index]),
                                      style: const TextStyle(
                                        color: textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 30,),
                      ],
                    ),
                  );
                },
              );
            }),
            icon: const Icon(
              Ionicons.filter_circle_outline,
              color: textPrimary,
            ),
          ),
          InkWell(
            onTap: (() {
              // change the sort from ascending to descending
              setState(() {
                _sortAscending = !_sortAscending;
                _filterList();
              });
            }),
            child: Container(
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
              ),
              child: _ascendingIcon(),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Total Value",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        formatCurrency(_args.value, false, false, false),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      const Text(
                        "Total Cost",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        formatCurrency(_args.cost, false, false, false),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Total Unrealised",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            trendIcon,
                            size: 12,
                            color: trendColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrencyWithNull(_args.unrealised, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: trendColor
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        "${(_args.unrealised ?? 0) > 0 ? '+' : ''}${formatDecimalWithNull((_args.cost > 0 ? ((_args.unrealised ?? 0) / _args.cost) : null), 100, 2)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: trendColor
                        ),
                      ),
                      const SizedBox(height: 5,),
                      const Text(
                        "Total Realised",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 5,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Ionicons.wallet_outline,
                            size: 12,
                            color: realisedColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrencyWithNull(_args.realised, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: realisedColor
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _portofolioFiltered.length,
              itemBuilder: ((context, index) {
                int colorMap = (index % Globals.colorList.length);
              
                return ProductListItem(
                  bgColor: Globals.colorList[colorMap],
                  title: (_args.type == 'reksadana' ? _portofolioFiltered[index].companyName : "(${_portofolioFiltered[index].companyCode}) ${_portofolioFiltered[index].companyName}"),
                  subTitle: "${formatDecimal(_portofolioFiltered[index].watchlistSubTotalShare, 2)} shares",
                  value: _portofolioFiltered[index].watchlistSubTotalValue,
                  cost: _portofolioFiltered[index].watchlistSubTotalCost,
                  realised: _portofolioFiltered[index].watchlistSubTotalRealised,
                  unrealised: _portofolioFiltered[index].watchlistSubTotalUnrealised,
                  total: _portofolioTotalValue,
                  netAssetValue: _portofolioFiltered[index].companyNetAssetValue,
                  oneDay: _portofolioFiltered[index].companyDailyReturn,
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _watchlistAPI.findSpecific(_args.type, _portofolioFiltered[index].watchlistId).then((resp) {
                      WatchlistListArgs watchlistArgs = WatchlistListArgs(
                        type: _args.type,
                        watchList: resp
                      );

                      // remove the loader dialog
                      Navigator.pop(context);

                      // go to the watchlist list page
                      Navigator.pushNamed(context, '/watchlist/list', arguments: watchlistArgs);
                    }).onError((error, stackTrace) {
                      // remove the loader dialog
                      Navigator.pop(context);

                      // show the error message
                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
                    });
                  }),
                );
              }),
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

  Widget _ascendingIcon() {
    String textUp = "A";
    String textDown = "Z";
    IconData currentIcon = Ionicons.arrow_down;

    if (!_sortAscending) {
      textUp = "Z";
      textDown = "A";
      currentIcon = Ionicons.arrow_up;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              textUp,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              textDown,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 2,),
        Icon(
          currentIcon,
          size: 20,
        )
      ],
    );
  }

  void _filterList() {
    _portofolioFiltered.clear();

    // since we will used portofolio list as based, just copy from here
    // this can be used as default value also for code/name
    _portofolioFiltered = _portofolioList.toList();

    // check what kind of sort type is being implemented
    // total investment, share left, realized pl, unrealized pl, one day
    switch(_sortType) {
      case "total":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalValue.compareTo(b.watchlistSubTotalValue));
        break;
      case "left":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalShare.compareTo(b.watchlistSubTotalShare));
        break;
      case "realizedpl":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalRealised.compareTo(b.watchlistSubTotalRealised));
        break;
      case "unrealizedpl":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalUnrealised.compareTo(b.watchlistSubTotalUnrealised));
        break;
      case "oneday":
        _portofolioFiltered.sort((a, b) => a.companyDailyReturn!.compareTo(b.companyDailyReturn!));
        break;
      default:
        // already copied above
        break;
    }

    // check if this is ascending of descending
    if (!_sortAscending) {
      _portofolioFiltered = _portofolioFiltered.reversed.toList();
    }
  }
}