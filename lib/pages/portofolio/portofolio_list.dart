import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/model/portofolio/portofolio_summary_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/widgets/chart/bar_chart.dart';
import 'package:my_wealth/widgets/list/product_list_item.dart';

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

  Color trendColor = Colors.white;
  Color realisedColor = Colors.white;
  IconData trendIcon = Ionicons.remove;
  bool _isLoading = true;
  double _portofolioTotalValue = 0;
  String _sortType = "type";
  bool _sortAscending = true;

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
    else if((_args.realised ?? 0) < 0) {
      realisedColor = secondaryColor;
    }

    Future.microtask(() async {
      showLoaderDialog(context);

      await _portofolioAPI.getPortofolioSummary(_args.type).then((resp) {
        _portofolioList = resp;

        // filter the data
        _filterList();

        // generate the _barChartData based on response
        _portofolioTotalValue = 0;
        for (PortofolioSummaryModel porto in resp) {
          _portofolioTotalValue += porto.portofolioTotalValue;
        }

        int index = 0;
        for (PortofolioSummaryModel porto in resp) {
          _barChartData.add(BarChartData(title: porto.portofolioCompanyDescription, value: porto.portofolioTotalValue, total: _portofolioTotalValue, color: Globals.colorList[index]));
          index = index + 1;
        }
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
            "Portofolio ${_args.title}",
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
                        "Unrealised Gain",
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
                            size: 15,
                            color: trendColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrency((_args.unrealised ?? 0), false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: trendColor
                            ),
                          ),
                        ],
                      ),
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
                        "Realised Gain",
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
                            size: 15,
                            color: realisedColor,
                          ),
                          const SizedBox(width: 5,),
                          Text(
                            formatCurrencyWithNull(_args.realised, false, false, false),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                int colorMap = (index % Globals.colorList.length);
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
                        subType: _portofolioFiltered[index].portofolioCompanyType
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
}