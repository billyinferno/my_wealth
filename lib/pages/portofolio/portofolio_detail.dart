import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/portofolio_api.dart';
import 'package:my_wealth/model/portofolio_detail_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/portofolio_list_args.dart';
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
  
  late PortofolioListArgs _args;
  
  late List<PortofolioDetailModel> _portofolioList;

  double _gain = 0;
  Color trendColor = Colors.white;
  IconData trendIcon = Ionicons.remove;
  bool _isLoading = true;
  double _portofolioTotalValue = 0;

  @override
  void initState() {
    // init list
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

      await _portofolioAPI.getPortofolioDetail(_args.type, _args.subType!).then((resp) {
        _portofolioList = resp;

        // generate the _barChartData based on response
        _portofolioTotalValue = 0;
        for (PortofolioDetailModel porto in resp) {
          _portofolioTotalValue += porto.watchlistSubTotalValue;
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
            _args.title,
            style: const TextStyle(
              color: secondaryColor,
            ),
          )
        ),
      ),
      body: SingleChildScrollView(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List<Widget>.generate(_portofolioList.length, ((index) {
                int colorMap = (index % Globals.colorList.length);
                
                return ProductListItem(
                  bgColor: Globals.colorList[colorMap],
                  title: (_portofolioList[index].companyCode.isNotEmpty ? "(${_portofolioList[index].companyCode}) ${_portofolioList[index].companyName}" : _portofolioList[index].companyName),
                  subTitle: "${formatDecimal(_portofolioList[index].watchlistSubTotalShare, 2)} share(s)",
                  value: _portofolioList[index].watchlistSubTotalValue,
                  cost: _portofolioList[index].watchlistSubTotalCost,
                  total: _portofolioTotalValue,
                );
              })),
            ),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }
}