import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/api/watchlist_api.dart';
import 'package:my_wealth/model/portofolio/portofolio_detail_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/arguments/watchlist_list_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_my_modal_bottom_sheet.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/widgets/list/product_list_item.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

class PortofolioDetailPage extends StatefulWidget {
  final Object? args;
  const PortofolioDetailPage({super.key, required this.args});

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

  Color _trendColor = Colors.white;
  Color _realisedColor = Colors.white;
  Color _totalGainColor = Colors.white;
  Color _totalDayGainColor = Colors.white;

  IconData _trendIcon = Ionicons.remove;
  double _portofolioTotalValue = 0;
  double _totalGain = 0;
  double _totalDayGain = 0;

  String _sortType = "cd";
  final Map<String, String> _sortMap = {
    "cd": "Code/Name",
    "tl": "Total Value",
    "lf": "Share Left",
    "rp": "Realized P/L",
    "up": "Unrealizd P/L",
    "1d": "Daily Gain (%)",
  };
  bool _sortAscending = true;

  late Future<bool> _getData;

  @override
  void initState() {
    // init list
    _portofolioList = [];
    _portofolioFiltered = [];

    // convert the arguments into portofilio list args
    _args = widget.args as PortofolioListArgs;

    // check unrealised and realised to determine the trend color and icon
    if((_args.unrealised ?? 0) > 0) {
      _trendColor = Colors.green;
      _trendIcon = Ionicons.trending_up;
    }
    else if((_args.unrealised ?? 0) < 0) {
      _trendColor = secondaryColor;
      _trendIcon = Ionicons.trending_down;
    }

    if((_args.realised ?? 0) > 0) {
      _realisedColor = Colors.green;
    }
    else if((_args.unrealised ?? 0) < 0) {
      _realisedColor = secondaryColor;
    }

    _totalGain = (_args.realised ?? 0) + (_args.unrealised ?? 0);
    if (_totalGain > 0) {
      _totalGainColor = Colors.green;
    }
    else if (_totalGain < 0) {
      _totalGainColor = secondaryColor;
    }

    // fetch the data from API
    _getData = _fetchData();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,      
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return CommonErrorPage(errorText: 'Error loading portofolio list of ${_args.title}');
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return const CommonLoadingPage();
        }
      }),
    );
  }

  Widget _generatePage() {
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
              ShowMyModalBottomSheet(
                context: context,
                filterList: _sortMap,
                filterMode: _sortType,
                onFilterSelect: ((value) {
                  setState(() {
                    _sortType = value;
                    _filterList();
                  });
                })
              ).show();
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
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
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
                      Text(
                        formatCurrency(_args.value, false, false, false),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2,),
                      const Text(
                        "Unrealised Gain",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            _trendIcon,
                            size: 13,
                            color: _trendColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrency((_args.unrealised ?? 0), false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _trendColor
                            ),
                          ),
                          const SizedBox(width: 2,),
                          Text(
                            "(${formatDecimalWithNull((_args.cost > 0 ? ((_args.unrealised ?? 0) / _args.cost) : null), 100, 0)}%)",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: _trendColor
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2,),
                      const Text(
                        "Realised Gain",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Ionicons.wallet_outline,
                            size: 13,
                            color: _realisedColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrencyWithNull(_args.realised, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _realisedColor
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        "Total Cost",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        formatCurrency(_args.cost, false, false, false),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2,),
                      const Text(
                        "Total Gain",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Ionicons.stats_chart,
                            size: 13,
                            color: _totalGainColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrency(_totalGain, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _totalGainColor
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2,),
                      const Text(
                        "Day Gain",
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Ionicons.today,
                            size: 13,
                            color: _totalDayGainColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrencyWithNull(_totalDayGain, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _totalDayGainColor
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  dayGain: _portofolioFiltered[index].watchlistSubTotalDayGain,
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
      case "tl":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalValue.compareTo(b.watchlistSubTotalValue));
        break;
      case "lf":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalShare.compareTo(b.watchlistSubTotalShare));
        break;
      case "rp":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalRealised.compareTo(b.watchlistSubTotalRealised));
        break;
      case "up":
        _portofolioFiltered.sort((a, b) => a.watchlistSubTotalUnrealised.compareTo(b.watchlistSubTotalUnrealised));
        break;
      case "1d":
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

  Future<bool> _fetchData() async {
    await _portofolioAPI.getPortofolioDetail(_args.type, _args.subType!).then((resp) {
      _portofolioList = resp;
      
      // generate the _barChartData based on response
      _portofolioTotalValue = 0;
      for (PortofolioDetailModel porto in resp) {
        _portofolioTotalValue += porto.watchlistSubTotalValue;

        // calculate total day gain
        _totalDayGain += porto.watchlistSubTotalDayGain;
      }

      // get the total day gain color
      if (_totalDayGain > 0) {
        _totalDayGainColor = Colors.green;
      }
      else if(_totalDayGain < 0) {
        _totalDayGainColor = secondaryColor;
      }

      // call filter
      _filterList();
    }).onError((error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw Exception("Error when get portofolio detail");
    });

    // return true if coming here 
    return false;
  }
}