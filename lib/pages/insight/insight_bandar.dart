import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

enum InsightBandarSubPage {
  atl30,
  nearATL30,
  topACQ,
  stockCollect,
  topEPS,
  sideways,
  indexBeater,
}

class InsightBandarPage extends StatefulWidget {
  const InsightBandarPage({super.key});

  @override
  State<InsightBandarPage> createState() => _InsightBandarPageState();
}

class _InsightBandarPageState extends State<InsightBandarPage> {
  late InsightBandarInterestModel _bandarInterest;
  InsightBandarSubPage _selectedBandarPage = InsightBandarSubPage.atl30;

  @override
  void initState() {
    super.initState();
    
    // get the data from shared preferences
    _bandarInterest = InsightSharedPreferences.getBandarInterestingList();
  }

  @override
  void dispose() {
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
              ScrollSegmentedControl<InsightBandarSubPage>(
                data: const {
                  InsightBandarSubPage.atl30: "ATL30",
                  InsightBandarSubPage.nearATL30: "Near-ATL30",
                  InsightBandarSubPage.topACQ: "Accumulation",
                  InsightBandarSubPage.stockCollect: "Stock Collection",
                  InsightBandarSubPage.topEPS: "EPS",
                  InsightBandarSubPage.sideways: "Sideways",
                  InsightBandarSubPage.indexBeater: "Index Beater",
                },
                onPress: ((value) {
                  setState(() {
                    _selectedBandarPage = value;
                  });
                })
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
    switch(_selectedBandarPage) {
      case InsightBandarSubPage.atl30:
        return InsightBandarAtlPage(
          title: "ATL30 Result",
          dialogTitle: "ATL30 Information",
          dialogDescription: "ATL30 is the list of stock where the current price is the lowest in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
          data: _bandarInterest.atl
        );
      case InsightBandarSubPage.nearATL30:
        return InsightBandarAtlPage(
          title: "Near-ATL30 Result",
          dialogTitle: "Near-ATL30 Information",
          dialogDescription: "Near-ATL30 is the list of stock where the current price is the nearly reach the lowest price in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
          data: _bandarInterest.nonAtl
        );
      case InsightBandarSubPage.topACQ:
        return const InsightBandarAccumulationPage();
      case InsightBandarSubPage.stockCollect:
        return const InsightBandarStockCollectPage();
      case InsightBandarSubPage.topEPS:
        return const InsightBandarEPSPage();
      case InsightBandarSubPage.sideways:
        return const InsightBandarSidewayPage();
      case InsightBandarSubPage.indexBeater:
        return const InsightBandarIndexBeaterPage();
    }
  }
}