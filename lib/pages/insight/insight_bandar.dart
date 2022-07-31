import 'package:flutter/cupertino.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/pages/insight/insight_bandar_page/insight_bandar_accumulation_page.dart';
import 'package:my_wealth/pages/insight/insight_bandar_page/insight_bandar_atl_page.dart';
import 'package:my_wealth/provider/inisght_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:provider/provider.dart';

class InsightBandarPage extends StatefulWidget {
  const InsightBandarPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarPage> createState() => _InsightBandarPageState();
}

class _InsightBandarPageState extends State<InsightBandarPage> {
  late InsightBandarInterestModel _bandarInterest;
  String _selectedBandarPage = "atl30";

  @override
  void initState() {
    // get the data from shared preferences
    _bandarInterest = InsightSharedPreferences.getBandarInterestingList();

    super.initState();
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
              SizedBox(
                width: double.infinity,
                child: CupertinoSegmentedControl(
                  children: const {
                    "atl30": Text("ATL30"),
                    "nearAtl30": Text("Near-ATL30"),
                    "topAcq": Text("Accumulation"),
                  },
                  onValueChanged: ((value) {
                    String selectedValue = value.toString();
                        
                    setState(() {
                      if(selectedValue == "atl30") {
                        _selectedBandarPage = "atl30";
                      }
                      else if(selectedValue == "nearAtl30") {
                        _selectedBandarPage = "nearAtl30";
                      }
                      else if(selectedValue == "topAcq") {
                        _selectedBandarPage = "topAcq";
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

    // default return nothing
    return const SizedBox.shrink();
  }
}