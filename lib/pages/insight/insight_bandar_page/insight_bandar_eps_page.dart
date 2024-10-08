import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarEPSPage extends StatefulWidget {
  const InsightBandarEPSPage({super.key});

  @override
  State<InsightBandarEPSPage> createState() => _InsightBandarEPSPageState();
}

class _InsightBandarEPSPageState extends State<InsightBandarEPSPage> {
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();
  final ScrollController _scrollController = ScrollController();

  late int _minEpsRate;
  late int _minEpsDiffRate;
  late List<InsightEpsModel> _epsList;

  late Future<bool> _getData;

  @override
  void initState() {
    super.initState();

    _minEpsRate = InsightSharedPreferences.getEpsMinRate();         // default to 0%
    _minEpsDiffRate = InsightSharedPreferences.getEpsMinDiffRate(); // default to 5%
    _epsList = InsightSharedPreferences.getEpsResult();             // default to empty list

    // get the data either from cache or from API
    _getData = _getInitData();
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
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(
            errorText: 'Error loading bandar accumulation page',
            isNeedScaffold: false,
          );
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage(
            isNeedScaffold: false,
          );
        }
      },
    );
  }

  Widget _body() {
    return Expanded(
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
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryLight,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "EPS Rate",
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 50,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: primaryDark
                            ),
                            child: Center(child: Text("$_minEpsRate%")),
                          ),
                          Expanded(
                            child: CupertinoSlider(
                              min: 0,
                              max: 100,
                              // divisions: 1,
                              value: _minEpsRate.toDouble(),
                              onChanged: ((value) {
                                setState(() {
                                  _minEpsRate = value.toInt();
                                });
                              })
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: primaryLight,
                      width: 1.0,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "EPS Diff Rate",
                        style: TextStyle(
                          color: secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 50,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: primaryLight,
                                width: 1.0,
                                style: BorderStyle.solid
                              ),
                              borderRadius: BorderRadius.circular(5),
                              color: primaryDark
                            ),
                            child: Center(child: Text("$_minEpsDiffRate%")),
                          ),
                          Expanded(
                            child: CupertinoSlider(
                              min: 0,
                              max: 100,
                              // divisions: 1,
                              value: _minEpsDiffRate.toDouble(),
                              onChanged: ((value) {
                                setState(() {
                                  _minEpsDiffRate = value.toInt();
                                });
                              })
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (() async {
              // show loading screen
              LoadingScreen.instance().show(context: context);

              // get the new data based on the rate change on the slider
              await _insightAPI.getTopEPS(
                minDiff: _minEpsRate,
                minDiffRate: _minEpsDiffRate,
              ).then((resp) async {
                _epsList = resp;
                
                // put on the shared preferences
                await InsightSharedPreferences.setEps(
                  minRate: _minEpsRate,
                  diffRate: _minEpsDiffRate,
                  epsList: _epsList
                );

                setState(() {
                  // just set state so we will rebuild the list view
                });
              }).whenComplete(() {
                LoadingScreen.instance().hide();
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
              itemCount: _epsList.length,
              itemBuilder: ((context, index) {
                return InkWell(
                  onTap: (() {
                    _getCompanyDetailAndGo(code: _epsList[index].code);
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(5),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              _epsList[index].code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              "(${formatDecimalWithNull(
                                _epsList[index].diffEpsRate,
                                times: 100,
                                decimal: 2
                              )}%)",
                              style: TextStyle(
                                fontSize: 12,
                                color: (_epsList[index].diffEpsRate < 0 ? secondaryColor : (_epsList[index].diffEpsRate > 0 ? Colors.green : textPrimary)),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _rowText(
                              title: "ONE MONTH",
                              value: "${formatDecimalWithNull(
                                _epsList[index].oneMonth,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: (
                                _epsList[index].oneMonth < 0 ?
                                secondaryColor :
                                (
                                  _epsList[index].oneMonth > 0 ?
                                  Colors.green :
                                  textPrimary
                                )
                              )
                            ),
                            const SizedBox(width: 5,),
                            _rowText(
                              title: "SIX MONTH",
                              value: "${formatDecimalWithNull(
                                _epsList[index].sixMonth,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: (
                                _epsList[index].sixMonth < 0 ?
                                secondaryColor :
                                (
                                  _epsList[index].sixMonth > 0 ?
                                  Colors.green :
                                  textPrimary
                                )
                              )
                            ),
                            const SizedBox(width: 5,),
                            _rowText(
                              title: "ONE YEAR",
                              value: "${formatDecimalWithNull(
                                _epsList[index].oneYear,
                                times: 100,
                                decimal: 2
                              )}%",
                              valueColor: (
                                _epsList[index].oneYear < 0 ?
                                secondaryColor : (
                                  _epsList[index].oneYear > 0 ?
                                  Colors.green :
                                  textPrimary
                                )
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 5,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _rowText(
                              title: "BUY LOT",
                              value: formatIntWithNull(
                                _epsList[index].buyLot,
                              )
                            ),
                            const SizedBox(width: 5,),
                            _rowText(
                              title: "SELL LOT",
                              value: formatIntWithNull(
                                _epsList[index].sellLot,
                              )
                            ),
                            const SizedBox(width: 5,),
                            _rowText(
                              title: "DIFF LOT",
                              value: formatIntWithNull(
                                _epsList[index].diffLot,
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _tableRowText(
                              title: "",
                              value1: "CURRENT",
                              value1Weight: FontWeight.bold,
                              value1Color: accentColor,
                              value2: "PREVIOUS",
                              value2Weight: FontWeight.bold,
                              value2Color: accentColor
                            ),
                            _tableRowText(
                              title: "Period",
                              value1: "${_epsList[index].currentPeriod}M ${_epsList[index].currentYear}",
                              value2: "${_epsList[index].prevPeriod}M ${_epsList[index].prevYear}"
                            ),
                            _tableRowText(
                              title: "Price",
                              value1: "${_epsList[index].currentPrice}",
                              value2: "${_epsList[index].prevPrice}"
                            ),
                            _tableRowText(
                              title: "Market Cap",
                              value1: formatIntWithNull(
                                _epsList[index].currentMarketCap,
                              ),
                              value2: formatIntWithNull(
                                _epsList[index].prevMarketCap,
                              )
                            ),
                            _tableRowText(
                              title: "Revenue",
                              value1: formatIntWithNull(
                                _epsList[index].currentRevenue,
                              ),
                              value2: formatIntWithNull(
                                _epsList[index].prevRevenue,
                              )
                            ),
                            _tableRowText(
                              title: "Net Profit",
                              value1: formatIntWithNull(
                                _epsList[index].currentNetProfit,
                              ),
                              value2: formatIntWithNull(
                                _epsList[index].prevNetProfit,
                              )
                            ),
                            _tableRowText(
                              title: "Deviden",
                              value1: formatDecimalWithNull(
                                _epsList[index].currentDeviden,
                              ),
                              value2: formatDecimalWithNull(
                                _epsList[index].prevDeviden,
                              )
                            ),
                            _tableRowText(
                              title: "EPS",
                              value1: formatDecimalWithNull(
                                _epsList[index].currentEps,
                              ),
                              value2: formatDecimalWithNull(
                                _epsList[index].prevEps,
                              )
                            ),
                            _tableRowText(
                              title: "EPS/Price",
                              value1: "${formatDecimalWithNull(
                                _epsList[index].currentEpsRate,
                                times: 100,
                                decimal: 2,
                              )}%",
                              value2: "${formatDecimalWithNull(
                                _epsList[index].prevEpsRate,
                                times: 100,
                                decimal: 2,
                              )}%"
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              })
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableRowText({required String title, required String value1, FontWeight? value1Weight, Color? value1Color, required String value2, FontWeight? value2Weight, Color? value2Color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: extendedLight,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: Text(
            value1,
            style: TextStyle(
              fontSize: 10,
              fontWeight: (value1Weight ?? FontWeight.normal),
              color: (value1Color ?? textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 5,),
        Expanded(
          child: Text(
            value2,
            style: TextStyle(
              fontSize: 10,
              fontWeight: (value2Weight ?? FontWeight.normal),
              color: (value2Color ?? textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowText({required String title, Color? titleColor, required String value, Color? valueColor}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (titleColor ?? extendedLight),
              fontSize: 10,
            ),
          ),
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

  Future<bool> _getInitData() async {
    // check if the _epsList is empry
    if (_epsList.isEmpty) {
      // get the insight data
      await _insightAPI.getTopEPS(
        minDiff: _minEpsRate,
        minDiffRate: _minEpsDiffRate,
      ).then((resp) async {
        _epsList = resp;

        // put on the shared preferences
        await InsightSharedPreferences.setEps(
          minRate: _minEpsRate,
          diffRate: _minEpsDiffRate,
          epsList: _epsList
        );
      }).onError((error, stackTrace) {
        Log.error(
          message: 'Error getting top EPS data',
          error: error,
          stackTrace: stackTrace,
        );
        throw Exception('Error when get Top EPS data from server');
      },);
    }

    return true;
  }

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get company detail and go
    await _companyAPI.getCompanyByCode(
      companyCode: code,
      type: 'saham',
    ).then((resp) {
      CompanyDetailArgs args = CompanyDetailArgs(
        companyId: resp.companyId,
        companyName: resp.companyName,
        companyCode: code,
        companyFavourite: (resp.companyFavourites ?? false),
        favouritesId: (resp.companyFavouritesId ?? -1),
        type: "saham",
      );
      
      if (mounted) {
        // go to the company page
        Navigator.pushNamed(context, '/company/detail/saham', arguments: args);
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        // show the error message
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: 'Error when try to get the company detail from server'));
      }
    }).whenComplete(() {
      // remove loading instance
      LoadingScreen.instance().hide();
    },);
  }
}