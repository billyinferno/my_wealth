import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/sector_summary_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/industry_summary_args.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/globals.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';

class InsightStockIndustryPage extends StatefulWidget {
  final Object? args;
  const InsightStockIndustryPage({Key? key, required this.args}) : super(key: key);

  @override
  State<InsightStockIndustryPage> createState() => _InsightStockIndustryPageState();
}

class _InsightStockIndustryPageState extends State<InsightStockIndustryPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final ScrollController _scrollController = ScrollController();

  late IndustrySummaryArgs _args;

  bool _isLoading = true;
  List<SectorSummaryModel> _industryList = [];

  @override
  void initState() {
    _args = widget.args! as IndustrySummaryArgs;
    _isLoading = true;
    
    super.initState();

    // get the result
    Future.microtask(() async {
      await _getIndustrySummary();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: primaryColor,
      );
    }
    else {
      return _generatePage();
    }
  }

  Widget _generatePage() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Ionicons.arrow_back,
          ),
          onPressed: (() {
            Navigator.pop(context);
          }),
        ),
        title: Center(
          child: Text(
            Globals.sectorName[_args.sectorData.sectorName]!,
            style: const TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: primaryDark,
                  height: 110,
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Globals.sectorIcon[_args.sectorData.sectorName]!,
                        color: accentColor,
                        size: 25,
                      ),
                      const SizedBox(height: 5,),
                      Text(
                        Globals.sectorName[_args.sectorData.sectorName]!,
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
                _summaryBar(sectorAverage: _args.sectorData.sectorAverage, fontSize: 13),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List<Widget>.generate(_industryList.length, (index) {
                    return _listItem(sectorName: _industryList[index].sectorName, sectorAverage: _industryList[index].sectorAverage);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem({required String sectorName, required SectorAverage sectorAverage}) {
    return InkWell(
      onTap: (() {
        //TODO: open all the company in this industry
        debugPrint("Open all the company in this industry");
      }),
      child: Container(
        height: 100,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              sectorName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _summaryBar(sectorAverage: sectorAverage, fontSize: 11, padding: 1),
                  const SizedBox(width: 5,),
                  const SizedBox(
                    width: 20,
                    child: Icon(
                      Ionicons.chevron_forward,
                      size: 20,
                      color: textPrimary,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBar({required SectorAverage sectorAverage, double? fontSize, double? padding}) {
    double fontSizeUse = (fontSize ?? 15);
    double paddingUse = (padding ?? 5);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _percentageBox(text: '1d', sectorAverage: sectorAverage.the1D, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '1w', sectorAverage: sectorAverage.the1W, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '1m', sectorAverage: sectorAverage.the1M, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '3m', sectorAverage: sectorAverage.the3M, fontSize: fontSizeUse, padding: paddingUse),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _percentageBox(text: '6m', sectorAverage: sectorAverage.the6M, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '1y', sectorAverage: sectorAverage.the1Y, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '3y', sectorAverage: sectorAverage.the3Y, fontSize: fontSizeUse, padding: paddingUse),
                _percentageBox(text: '5y', sectorAverage: sectorAverage.the5Y, fontSize: fontSizeUse, padding: paddingUse),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _percentageBox({required String text, required double sectorAverage, required double fontSize, required double padding}) {
    Color bgColor = (sectorAverage >= 0 ? Colors.green : secondaryColor);
    Color borderColor = (sectorAverage >= 0 ? const Color.fromARGB(255, 15, 88, 17) : secondaryDark);

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            style: BorderStyle.solid,
            width: 1.0,
          ),
          color: bgColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            SizedBox(height: padding,),
            Text(
              '${formatDecimal((sectorAverage * 100), 2)}%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getIndustrySummary() async {
    // show the loader
    showLoaderDialog(context);

    // get the industry summary from backend
    await _insightAPI.getIndustrySummary(_args.sectorData.sectorName).then((resp) {
      // set the industry list with the response
      _industryList = resp;
    }).whenComplete(() {
      // remove the loader
      Navigator.pop(context);

      // set state to refresh the page
      setState(() {
        _isLoading = false;
      });
    });
  }
}