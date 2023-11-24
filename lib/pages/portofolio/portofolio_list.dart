import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/model/portofolio/portofolio_summary_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/widgets/chart/bar_chart.dart';
import 'package:my_wealth/widgets/list/product_list_item.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

class PortofolioListPage extends StatefulWidget {
  final Object? args;
  const PortofolioListPage({Key? key, required this.args}) : super(key: key);

  @override
  State<PortofolioListPage> createState() => _PortofolioListPageState();
}

class _PortofolioListPageState extends State<PortofolioListPage> {
  final ScrollController _scrollController = ScrollController();
  final PortofolioAPI _portofolioAPI = PortofolioAPI();
  
  late PortofolioListArgs _args;
  
  late List<BarChartData> _barChartData;
  late List<PortofolioSummaryModel> _portofolioList;
  late List<PortofolioSummaryModel> _portofolioFiltered;
  late Future<bool> _getData;

  final Map<String, String> _sortMap = {
    "type": "Type",
    "total": "Total Product(s)",
    "share": "Total Share",
    "cost": "Total Cost",
    "value": "Total Value",
    "realized": "Total Realized P/L",
    "unrealized": "Total Unrealized P/L",
  };
  final List<String> _sortList = ["type", "total", "share", "cost", "value", "realized", "unrealized"];

  Color _trendColor = Colors.white;
  Color _realisedColor = Colors.white;
  Color _totalGainColor = Colors.white;
  Color _totalDayGainColor = Colors.white;
  IconData _trendIcon = Ionicons.remove;
  double _portofolioTotalValue = 0;
  double _totalGain = 0;
  double _totalDayGain = 0;
  String _sortType = "type";
  bool _sortAscending = true;
  bool _showSort = true;

  @override
  void initState() {
    // init list
    _barChartData = [];
    _portofolioList = [];
    _portofolioFiltered = [];

    // convert the arguments into portofilio list args
    _args = widget.args as PortofolioListArgs;

    // check realised and unrealised to determine the trend color and icon
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
    else if((_args.realised ?? 0) < 0) {
      _realisedColor = secondaryColor;
    }

    _totalGain = (_args.realised ?? 0) + (_args.unrealised ?? 0);
    if (_totalGain > 0) {
      _totalGainColor = Colors.green;
    }
    else if (_totalGain < 0) {
      _totalGainColor = secondaryColor;
    }

    // get portofolio summary
    _getData = _getPortofolioSummary();

    // get show sort
    _showSort = (_args.showSort ?? true);

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
      })
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
            "Portofolio ${_args.title}",
            style: const TextStyle(
              color: secondaryColor,
            ),
          )
        ),
        actions: <Widget>[
          Visibility(
            visible: _showSort,
            child: IconButton(
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
          BarChart(
            data: _barChartData,
            showLegend: false,
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _portofolioFiltered.length,
              itemBuilder: (context, index) {
                int colorMap = _getColorMap(_portofolioFiltered[index].portofolioCompanyDescription, index);
                
                return ProductListItem(
                  onTap: (() {
                    // convert the total product
                    int? numProd = _portofolioFiltered[index].portofolioTotalProduct;
            
                    // check if we have product here or not?
                    if (numProd > 0) {
                      // got product means we can display the details here 
                      PortofolioListArgs args = PortofolioListArgs(
                        title: _portofolioFiltered[index].portofolioCompanyDescription,
                        value: _portofolioFiltered[index].portofolioTotalValue,
                        cost: _portofolioFiltered[index].portofolioTotalCost,
                        realised: _portofolioFiltered[index].portofolioTotalRealised,
                        unrealised: _portofolioFiltered[index].portofolioTotalUnrealised,
                        type: _args.type,
                        subType: _portofolioFiltered[index].portofolioCompanyType,
                        showSort: true,
                      );
            
                      Navigator.pushNamed(context, '/portofolio/list/detail', arguments: args);
                    }
                  }),
                  bgColor: Globals.colorList[colorMap],
                  title: _portofolioFiltered[index].portofolioCompanyDescription,
                  subTitle: "${_portofolioFiltered[index].portofolioTotalProduct} product${_portofolioFiltered[index].portofolioTotalProduct > 1 ? "s" : ""}",
                  value: _portofolioFiltered[index].portofolioTotalValue,
                  cost: _portofolioFiltered[index].portofolioTotalCost,
                  realised: _portofolioFiltered[index].portofolioTotalRealised,
                  dayGain: _portofolioFiltered[index].portofolioTotalDayGain,
                  total: _portofolioTotalValue,
                );
              },
            ),
          ),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

  int _getColorMap(String name, int index) {
    switch(name.toLowerCase()) {
      case "campuran":
        return 0;
      case "pasar uang":
        return 1;
      case "pendapatan tetap":
        return 2;
      case "saham":
        return 3;
      default:
        return (index % Globals.colorList.length);
    }
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
    // "total", "share", "cost", "value", "realized", "unrealized"
    switch(_sortType) {
      case "total":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalProduct.compareTo(b.portofolioTotalProduct));
        break;
      case "share":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalShare.compareTo(b.portofolioTotalShare));
        break;
      case "cost":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalCost.compareTo(b.portofolioTotalCost));
        break;
      case "value":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalValue.compareTo(b.portofolioTotalValue));
        break;
      case "realized":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalRealised.compareTo(b.portofolioTotalRealised));
        break;
      case "unrealized":
        _portofolioFiltered.sort((a, b) => a.portofolioTotalUnrealised.compareTo(b.portofolioTotalUnrealised));
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

  Future<bool> _getPortofolioSummary() async {
    try {
      await _portofolioAPI.getPortofolioSummary(_args.type).then((resp) {
        _portofolioList = resp;

        // filter the data
        _filterList();

        _portofolioTotalValue = 0;
        int index = 0;

        // calculate the total value
        for (PortofolioSummaryModel porto in resp) {
          _portofolioTotalValue += porto.portofolioTotalValue;
        }

        // generate the _barChartData based on response
        for (PortofolioSummaryModel porto in resp) {          
          // add bar chart for this portotolio
          _barChartData.add(BarChartData(title: porto.portofolioCompanyDescription, value: porto.portofolioTotalValue, total: _portofolioTotalValue, color: Globals.colorList[_getColorMap(porto.portofolioCompanyDescription, index)]));
          index = index + 1;

          // calculate total day gain
          _totalDayGain += porto.portofolioTotalDayGain;
        }

        // get the total day gain color
        if (_totalDayGain > 0) {
          _totalDayGainColor = Colors.green;
        }
        else if(_totalDayGain < 0) {
          _totalDayGainColor = secondaryColor;
        }
      });
    }
    catch(error) {
      debugPrint(error.toString());
      throw 'Error when try to get the data from server';
    }

    return true;
  }
}