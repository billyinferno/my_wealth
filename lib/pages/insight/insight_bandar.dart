import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarPage extends StatefulWidget {
  const InsightBandarPage({super.key});

  @override
  State<InsightBandarPage> createState() => _InsightBandarPageState();
}

class _InsightBandarPageState extends State<InsightBandarPage> {
  late InsightBandarInterestModel _bandarInterest;
  String _selectedBandarPage = "atl30";

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
              ScrollSegmentedControl(
                data: const {
                  "atl30": "ATL30",
                  "nearAtl30": "Near-ATL30",
                  "topAcq": "Accumulation",
                  "stockCollect": "Stock Collection",
                  "topEps": "EPS",
                  "sideways": "Sideways",
                  "indexBeater": "Index Beater",
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
    if (_selectedBandarPage == "atl30") {
      return InsightBandarAtlPage(
        title: "ATL30 Result",
        dialogTitle: "ATL30 Information",
        dialogDescription: "ATL30 is the list of stock where the current price is the lowest in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
        data: _bandarInterest.atl
      );
    }
    if (_selectedBandarPage == "nearAtl30") {
      return InsightBandarAtlPage(
        title: "Near-ATL30 Result",
        dialogTitle: "Near-ATL30 Information",
        dialogDescription: "Near-ATL30 is the list of stock where the current price is the nearly reach the lowest price in the last 30-days of trading date.\n\nThis is curated with stock where the volume of the transaction is active (more than average volume for 20 days)",
        data: _bandarInterest.nonAtl
      );
    }
    if (_selectedBandarPage == "topAcq") {
      return const InsightBandarAccumulationPage();
    }
    if (_selectedBandarPage == "stockCollect") {
      return const InsightBandarStockCollectPage();
    }
    if (_selectedBandarPage == "topEps") {
      return const InsightBandarEPSPage();
    }
    if (_selectedBandarPage == "sideways") {
      return const InsightBandarSidewayPage();
    }
    if (_selectedBandarPage == "indexBeater") {
      return const InsightBandarIndexBeaterPage();
    }

    // default return nothing
    return const SizedBox.shrink();
  }
}