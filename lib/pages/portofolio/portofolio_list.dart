import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/model/portofolio_summary_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/widgets/bar_chart.dart';
import 'package:my_wealth/widgets/product_list_item.dart';

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

  double _gain = 0;
  Color trendColor = Colors.white;
  IconData trendIcon = Ionicons.remove;
  bool _isLoading = true;
  double _portofolioTotalValue = 0;

  @override
  void initState() {
    // init list
    _barChartData = [];
    _portofolioList = [];

    // convert the arguments into portofilio list args
    _args = widget.args as PortofolioListArgs;
    _gain = _args.value - _args.cost;

    // check gain to determine the trend color and icon
    if(_gain > 0) {
      trendColor = Colors.green;
      trendIcon = Ionicons.trending_up;
    }
    else if(_gain < 0) {
      trendColor = secondaryColor;
      trendIcon = Ionicons.trending_down;
    }

    Future.microtask(() async {
      showLoaderDialog(context);

      await _portofolioAPI.getPortofolioSummary(_args.type).then((resp) {
        _portofolioList = resp;

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
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                                "Total",
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
                                "Gain",
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
                                    formatCurrency(_gain, false, false, false),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: trendColor
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "${_gain > 0 ? '+' : ''}${formatDecimal((_gain / _args.value), 2)}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: trendColor
                                ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List<Widget>.generate(_portofolioList.length, ((index) {
                      int colorMap = (index % Globals.colorList.length);
                      return ProductListItem(
                        onTap: (() {
                          // convert the total product
                          int? numProd = int.tryParse(_portofolioList[index].portofolioTotalProduct);
                          numProd = numProd ?? 0;
          
                          // check if we have product here or not?
                          if (numProd > 0) {
                            // got product means we can display the details here 
                            PortofolioListArgs args = PortofolioListArgs(
                              title: _portofolioList[index].portofolioCompanyDescription,
                              value: _portofolioList[index].portofolioTotalValue,
                              cost: _portofolioList[index].portofolioTotalCost,
                              type: _args.type,
                              subType: _portofolioList[index].portofolioCompanyType
                            );
          
                            Navigator.pushNamed(context, '/portofolio/list/detail', arguments: args);
                          }
                        }),
                        bgColor: Globals.colorList[colorMap],
                        title: _portofolioList[index].portofolioCompanyDescription,
                        subTitle: "- ${_portofolioList[index].portofolioTotalProduct} product(s)",
                        value: _portofolioList[index].portofolioTotalValue,
                        cost: _portofolioList[index].portofolioTotalCost,
                        total: _portofolioTotalValue,
                      );
                    })),
                  ),
                  const SizedBox(height: 30,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}