import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/api/insight_api.dart';
import 'package:my_wealth/model/insight_sideway_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/utils/prefs/shared_insight.dart';
import 'package:my_wealth/widgets/number_stepper.dart';

class InsightBandarSidewayPage extends StatefulWidget {
  const InsightBandarSidewayPage({Key? key}) : super(key: key);

  @override
  State<InsightBandarSidewayPage> createState() => _InsightBandarSidewayPageState();
}

class _InsightBandarSidewayPageState extends State<InsightBandarSidewayPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final TextStyle _headerStyle = const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12, overflow: TextOverflow.ellipsis);
  final ScrollController _scrollController = ScrollController();

  late List<InsightSidewayModel> _sidewayList;
  late int _maxOneDay;
  late int _avgOneDay;
  late int _avgOneWeek;

  bool _isLoading = true;

  @override
  void initState() {
    // initialize all the default variable
    _maxOneDay = InsightSharedPreferences.getSidewayOneDayRate();
    _avgOneDay = InsightSharedPreferences.getSidewayAvgOneDay();
    _avgOneWeek = InsightSharedPreferences.getSidewayAvgOneWeek();
    _sidewayList = InsightSharedPreferences.getSidewayResult();

    // check if we already got result or not?
    if (_sidewayList.isEmpty) {
      Future.microtask(() async {
        // show loader
        showLoaderDialog(context);

        // get the sideway data
        await _insightAPI.getSideway(_maxOneDay, _avgOneDay, _avgOneWeek).then((resp) async {
          _sidewayList = resp;

          // stored the sideway result to shared preferences
          await InsightSharedPreferences.setSideway(_maxOneDay, _avgOneDay, _avgOneWeek, _sidewayList);
        });
      }).whenComplete(() {
        Navigator.pop(context);
        setLoading(false);
      });
    }
    else {
      // already got result, just set the loading into false
      // so we can render the page automatically
      setLoading(false);
    }

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if loading show text loading
    if (_isLoading) {
      return const Expanded(child: Center(child: Text("Loading Sideway Data"),));
    }

    // else return the main widget
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: "Sideways",
                text: "This will find the average one day increment/decrement for 5 days, and one week increment/decrement for 10 days, based on the parameter configured above.\n\nThe parameter for the average one day or one week will be calculate between (+ and -).",
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Sideways",
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Max 1 Day",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _maxOneDay,
                      onTap: ((value) {
                        _maxOneDay = value;
                      })
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Avg 1 Day (+/-)",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _avgOneDay,
                      onTap: ((value) {
                        _avgOneDay = value;
                      })
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Avg 1 Week (+/-)",
                      style: _headerStyle,
                    ),
                    const SizedBox(height: 5,),
                    NumberStepper(
                      bgColor: primaryDark,
                      textColor: textPrimary,
                      borderColor: primaryLight,
                      initialRate: _avgOneWeek,
                      onTap: ((value) {
                        _avgOneWeek = value;
                      })
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (() async {
              showLoaderDialog(context);
              await _insightAPI.getSideway(_maxOneDay, _avgOneDay, _avgOneWeek).then((resp) async {
                _sidewayList = resp;

                // stored the sideway result to shared preferences
                await InsightSharedPreferences.setSideway(_maxOneDay, _avgOneDay, _avgOneWeek, _sidewayList);
              }).whenComplete(() {
                Navigator.pop(context);
              }).onError((error, stackTrace) {
                debugPrintStack(stackTrace: stackTrace);
                ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when try to retrieve sideway data"));
              });

              setState(() {
                // just set stat to refresh the widget
              });
            }),
            child: Container(
              height: 30,
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryDark,
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid
                )
              ),
              child: const Center(
                child: Text(
                  "Show Result",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sidewayList.length,
              itemBuilder: ((context, index) {
                return InkWell(
                  onTap: (() async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(_sidewayList[index].code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: _sidewayList[index].code,
                        companyFavourite: (resp.companyFavourites ?? false),
                        favouritesId: (resp.companyFavouritesId ?? -1),
                        type: "saham",
                      );
                      
                      // remove the loader dialog
                      Navigator.pop(context);

                      // go to the company page
                      Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
                    }).onError((error, stackTrace) {
                      // remove the loader dialog
                      Navigator.pop(context);

                      // show the error message
                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
                    });
                  }),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: primaryLight,
                          width: 1.0,
                          style: BorderStyle.solid,
                        )
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _sidewayList[index].code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnInfo(title: "Price", value: formatCurrency(_sidewayList[index].lastPrice.toDouble(), false, false, false), valueColor: _getValueColorInt(_sidewayList[index].lastPrice, _sidewayList[index].prevClosingPrice)),
                            _columnInfo(title: "Prev Price", value: formatCurrency(_sidewayList[index].prevClosingPrice.toDouble(), false, false, false)),
                            _columnInfo(title: "AVG Daily", value: "${formatDecimalWithNull(_sidewayList[index].avgDaily, 100, 2)}%", valueColor: _getValueColorDouble(_sidewayList[index].avgDaily, 0)),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _columnInfo(title: "One Day", value: "${formatDecimalWithNull(_sidewayList[index].oneDay, 100, 2)}%", valueColor: _getValueColorDouble(_sidewayList[index].oneDay, 0)),
                            _columnInfo(title: "One Week", value: "${formatDecimalWithNull(_sidewayList[index].oneWeek, 100, 2)}%", valueColor: _getValueColorDouble(_sidewayList[index].oneWeek,  0)),
                            _columnInfo(title: "One Month", value: "${formatDecimalWithNull(_sidewayList[index].oneMonth, 100, 2)}%", valueColor: _getValueColorDouble(_sidewayList[index].oneMonth, 0)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getValueColorInt(int? value, int? compare) {
    if (value == null || compare == null) {
      return Colors.white70;
    }

    if (value < compare) {
      return secondaryColor;
    }
    else if (value > compare) {
      return Colors.green;
    }
    else {
      return textPrimary;
    }
  }

  Color _getValueColorDouble(double? value, double? compare) {
    if (value == null || compare == null) {
      return Colors.white70;
    }

    if (value < compare) {
      return secondaryColor;
    }
    else if (value > compare) {
      return Colors.green;
    }
    else {
      return textPrimary;
    }
  }

  Widget _columnInfo({required String title, Color? titleColor, required String value, Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: (titleColor ?? extendedLight),
            ),
          ),
          const SizedBox(height: 2,),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: (valueColor ?? textPrimary)
            ),
          ),
        ],
      ),
    );
  }

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }
}