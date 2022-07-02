import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:provider/provider.dart';

class InsightBandarPage extends StatefulWidget {
  const InsightBandarPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarPage> createState() => _InsightBandarPageState();
}

class _InsightBandarPageState extends State<InsightBandarPage> {
  final ScrollController _scrollControllerATL = ScrollController();
  final ScrollController _scrollControllerNonATL = ScrollController();

  late InsightBandarInterestModel _bandarInterest;
  String _selectedBandarPage = "a";

  @override
  void initState() {
    // get the data from shared preferences
    _bandarInterest = InsightSharedPreferences.getBandarInterestingList();

    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerATL.dispose();
    _scrollControllerNonATL.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(
      builder: ((context, insightProvider, child) {
        // if provider data not null then use the one from provider
        if (insightProvider.bandarInterestList != null) {
          _bandarInterest = insightProvider.bandarInterestList!;
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl(
                  children: const {
                    "a": Text("ATL30"),
                    "n": Text("Non-ATL30"),
                    "s": Text("Screener"),
                  },
                  onValueChanged: ((value) {
                    String selectedValue = value.toString();
                        
                    setState(() {
                      if(selectedValue == "a") {
                        _selectedBandarPage = "a";
                      }
                      else if(selectedValue == "n") {
                        _selectedBandarPage = "n";
                      }
                      else if(selectedValue == "s") {
                        _selectedBandarPage = "s";
                      }
                    });
                  }),
                  groupValue: _selectedBandarPage,
                  selectedColor: secondaryColor,
                  borderColor: secondaryDark,
                  pressedColor: primaryDark,
                ),
              ),
              const SizedBox(height: 10,),
              _showPage(),
            ],
          ),
        );
      }),
    );
  }

  Widget _showPage() {
    if (_selectedBandarPage == "a") {
      return _atlPage();
    }
    if (_selectedBandarPage == "n") {
      return _nonAtlPage();
    }
    if (_selectedBandarPage == "s") {
      return _screenerPage();
    }

    // default return nothing
    return const SizedBox.shrink();
  }

  Widget _screenerPage() {
    //TODO: create actual screener page
    return const Center(child: Text("Screener Coming Soon"),);
  }

  Widget _atlPage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "ATL30 Information",
                text: "ATL30 is the list of stock where the current price is the lowest in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "ATL30 Result",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor
                  ),
                ),
                SizedBox(width: 5,),
                Icon(
                  Ionicons.information_circle,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollControllerATL,
              itemCount: _bandarInterest.atl.length,
              itemBuilder: ((context, index) {
                return _item(data: _bandarInterest.atl[index]);            
              })
            ),
          )
        ],
      ),
    );
  }
  
  Widget _nonAtlPage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "Non-ATL30 Information",
                text: "Non-ATL30 is the list of stock where the current price is the nearly reach the lowest price in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  "Non-ATL30 Result",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor
                  ),
                ),
                SizedBox(width: 5,),
                Icon(
                  Ionicons.information_circle,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollControllerATL,
              itemCount: _bandarInterest.nonAtl.length,
              itemBuilder: ((context, index) {
                return _item(data: _bandarInterest.nonAtl[index]);            
              })
            ),
          )
        ],
      ),
    );
  }

  Widget _item({required BandarInterestAttributes data}) {
    return InkWell(
      onTap: (() {
        // create the company args
        CompanyDetailArgs args = CompanyDetailArgs(
          companyId: data.companyId,
          companyName: data.name,
          companyCode: data.code,
          companyFavourite: false,
          favouritesId: -1,
          type: 'saham'
        );

        Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
      }),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              style: BorderStyle.solid,
              width: 1.0,
            )
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: _text(
                    text: "(${data.code})",
                    color: secondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: _text(
                    text: data.name
                  )
                ),
                const SizedBox(width: 5,),
                _text(text: formatIntWithNull(data.lastPrice)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "Volume", text: formatIntWithNull(int.tryParse(data.volume))),
                _column(title: "High", text: formatIntWithNull(data.adjustedHighPrice)),
                _column(title: "Low", text: formatIntWithNull(data.adjustedLowPrice)),
                _column(title: "Min30", text: formatIntWithNull(data.min30Price)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "MA5", text: formatIntWithNull(data.ma5), color: (data.ma5 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA8", text: formatIntWithNull(data.ma8), color: (data.ma8 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA13", text: formatIntWithNull(data.ma13), color: (data.ma13 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA20", text: formatIntWithNull(data.ma20), color: (data.ma20 < data.lastPrice ? secondaryColor : textPrimary)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "1 day", text: formatDecimalWithNull(data.oneDay, 100, 2), color: (data.oneDay < 0 ? secondaryColor : textPrimary)),
                _column(title: "1 week", text: formatDecimalWithNull(data.oneWeek, 100, 2), color: (data.oneWeek < 0 ? secondaryColor : textPrimary)),
                _column(title: "1 month", text: formatDecimalWithNull(data.oneMonth, 100, 2), color: (data.oneMonth < 0 ? secondaryColor : textPrimary)),
                _column(title: "ytd", text: formatDecimalWithNull(data.ytd, 100, 2), color: (data.ytd < 0 ? secondaryColor : textPrimary)),
              ],
            ),
            const SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }

  Widget _text({required String text, FontWeight? fontWeight, Color? color, double? fontSize}) {
    FontWeight currentFontWeight = (fontWeight ?? FontWeight.normal);
    Color currentColor = (color ?? textPrimary);
    double currentFontSize = (fontSize ?? 12);

    return Text(
      text,
      style: TextStyle(
        fontWeight: currentFontWeight,
        color: currentColor,
        fontSize: currentFontSize,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _column({required String title, required String text, Color? color}) {
    Color colorUse = (color ?? textPrimary);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _text(
              text: title,
              fontWeight: FontWeight.bold,
              color: extendedLight,
            ),
            const SizedBox(height: 5,),
            _text(
              text: text,
              color: colorUse
            ),
          ],
        ),
      ),
    );
  }
}