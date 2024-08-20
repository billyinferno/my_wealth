import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class CompanyDetailCryptoPage extends StatefulWidget {
  final Object? companyData;
  const CompanyDetailCryptoPage({super.key, required this.companyData});

  @override
  State<CompanyDetailCryptoPage> createState() => _CompanyDetailCryptoPageState();
}

class _CompanyDetailCryptoPageState extends State<CompanyDetailCryptoPage> {
  final ScrollController _summaryController = ScrollController();
  final ScrollController _priceController = ScrollController();
  final ScrollController _calendarScrollController = ScrollController();
  final ScrollController _graphScrollController = ScrollController();

  late CompanyDetailArgs _companyData;
  late CompanyDetailModel _companyDetail;
  late UserLoginInfoModel? _userInfo;
  late Map<DateTime, int> _watchlistDetail;
  late Future<bool> _getData;
  
  final CompanyAPI _companyApi = CompanyAPI();
  final WatchlistAPI _watchlistAPI = WatchlistAPI();
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  final Bit _bitData = Bit();

  bool _showCurrentPriceComparison = false;
  late List<GraphData> _graphData;
  late Map<DateTime, GraphData> _heatGraphData;

  late List<WatchlistListModel> _watchlists;
  late bool _isOwned;
  
  int _numPrice = 0;
  int _bodyPage = 0;

  double? _minPrice;
  double? _maxPrice;
  double? _avgPrice;

  @override
  void initState() {
    super.initState();

    // convert company arguments
    _companyData = widget.companyData as CompanyDetailArgs;

    // get user information
    _userInfo = UserSharedPreferences.getUserInfo();

    // get the user watchlist for crypto
    _watchlists = WatchlistSharedPreferences.getWatchlist("crypto");
    _isOwned = false;

    // initialize graph data
    _graphData = [];
    _heatGraphData = {};

    // assuming we don't have any watchlist detail
    _watchlistDetail = {};

    // get initial data
    _getData = _getInitData();    
  }

  @override
  void dispose() {
    super.dispose();
    _summaryController.dispose();
    _priceController.dispose();
    _calendarScrollController.dispose();
    _graphScrollController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading crypto data');
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return const CommonLoadingPage();
        }
      })
    );
  }

  Widget _generatePage() {
    IconData currentIcon = Ionicons.remove;

    if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) > 0) {
      currentIcon = Ionicons.caret_up;
    }
    else if ((_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!) < 0) {
      currentIcon = Ionicons.caret_down;
    }
    // generate the actual page
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Crypto Detail",
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (() async {
              Navigator.pop(context);
            }),
          ),
          actions: <Widget>[
            Visibility(
              visible: _isOwned,
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: const Icon(
                  Ionicons.checkmark,
                  color: Colors.green,
                ),
              ),
            ),
            Icon(
              (_companyData.companyFavourite ? Ionicons.star : Ionicons.star_outline),
              color: accentColor,
            ),
            const SizedBox(width: 20,),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            (_companyDetail.companySymbol == null ? "" : "(${_companyDetail.companySymbol!.toUpperCase()}) ") + _companyData.companyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                formatCurrency(_companyDetail.companyNetAssetValue!),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                "USD ${formatCurrency(_companyDetail.companyCurrentPriceUsd!)}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                currentIcon,
                                color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
                              ),
                              const SizedBox(width: 10,),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrevPrice!, _userInfo!.risk),
                                      width: 2.0,
                                      style: BorderStyle.solid,
                                    ),
                                  )
                                ),
                                child: Text(formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrevPrice!)),
                              ),
                              Expanded(child: Container(),),
                              const Icon(
                                Ionicons.time_outline,
                                color: primaryLight,
                              ),
                              const SizedBox(width: 10,),
                              Text(formatDateWithNulll(date: _companyDetail.companyLastUpdate, format: _df)),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Market Cap",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_companyDetail.companyMarketCap),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Rank",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatIntWithNull(_companyDetail.companyMarketCapRank),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Fully Dilluted",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_companyDetail.companyFullyDilutedValuation),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              CompanyInfoBox(
                                header: "Min ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_minPrice!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Max ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_maxPrice!),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              CompanyInfoBox(
                                header: "Avg ($_numPrice)",
                                headerAlign: MainAxisAlignment.end,
                                child: Text(
                                  formatCurrencyWithNull(_avgPrice!),
                                  textAlign: TextAlign.right,
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
            ),
            const SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Info",
                  bgColor: primaryDark,
                  icon: Ionicons.speedometer_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 0;
                    });
                  }),
                  active: (_bodyPage == 0),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Table",
                  bgColor: primaryDark,
                  icon: Ionicons.list_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 1;
                    });
                  }),
                  active: (_bodyPage == 1),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Map",
                  bgColor: primaryDark,
                  icon: Ionicons.calendar_clear_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 2;
                    });
                  }),
                  active: (_bodyPage == 2),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
                TransparentButton(
                  text: "Graph",
                  bgColor: primaryDark,
                  icon: Ionicons.stats_chart_outline,
                  callback: (() {
                    setState(() {
                      _bodyPage = 3;
                    });
                  }),
                  active: (_bodyPage == 3),
                  vertical: true,
                ),
                const SizedBox(width: 10,),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(child: _detail()),
            const SizedBox(height: 30,),
          ],
        ),
      ),
    );
  }

  Widget _detail() {
    switch(_bodyPage) {
      case 0:
        return _showSummary();
      case 1:
        return _showTable();
      case 2:
        return _showCalendar();
      case 3:
        return _showGraph();
      default:
        return _showSummary();
    }
  }

  Widget _showSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              controller: _summaryController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "Total Volume",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          formatCurrencyWithNull(_companyDetail.companyTotalUnit),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "Circulating",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          formatCurrencyWithNull(_companyDetail.companyCirculatingSupply),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "Total Supply",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          formatCurrencyWithNull(_companyDetail.companyTotalSupply),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "Max Supply",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          formatCurrencyWithNull(_companyDetail.companyMaxSupply),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "High 24H",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyHigh24H)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "Low 24H",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyLow24H)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "Price Change 24H",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyPriceChange24H)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "%",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "${formatDecimalWithNull(_companyDetail.companyPriceChangePercentage24H, 100, 4)}%",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "Market Cap Chg 24H",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyMarketCapChange24H)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "%",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "${formatDecimalWithNull(_companyDetail.companyMarketCapChangePercentage24H, 100, 4)}%",
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "ATH",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyAllTimeHigh)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "%",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "${formatDecimalWithNull(_companyDetail.companyAllTimeHighChangePercentage, 1, 4)}%",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "Date",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          (_companyDetail.companyAllTimeHighDate == null ? "" : _df.format(_companyDetail.companyAllTimeHighDate!)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CompanyInfoBox(
                        header: "ATL",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "\$ ${formatCurrencyWithNull(_companyDetail.companyAllTimeLow)}",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "%",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          "${formatDecimalWithNull(_companyDetail.companyAllTimeLowChangePercentage, 1, 4)}%",
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      CompanyInfoBox(
                        header: "Date",
                        headerAlign: MainAxisAlignment.end,
                        child: Text(
                          (_companyDetail.companyAllTimeHighDate == null ? "" : _df.format(_companyDetail.companyAllTimeLowDate!)),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ),
      ],
    );
  }

  Widget _showTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 10,),
            Expanded(
              child: Container(
                color: primaryColor,
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Text(
                          "Price",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.swap_vertical,
                            size: 16,
                          ),
                        ),
                      )
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 21,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid,
                            )
                          )
                        ),
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Ionicons.pulse_outline,
                            size: 16,
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: _priceController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _companyDetail.companyPrices.length,
            itemBuilder: (context, index) {
              double? dayDiff;
              Color dayDiffColor = Colors.transparent;
              if((index+1) < _companyDetail.companyPrices.length) {
                double currPrice = _companyDetail.companyPrices[index].priceValue;
                double prevPrice = _companyDetail.companyPrices[index + 1].priceValue;
                dayDiff = currPrice - prevPrice;
                dayDiffColor = riskColor(currPrice, prevPrice, _userInfo!.risk);
              }
              return CompanyDetailPriceList(
                date: _df.format(_companyDetail.companyPrices[index].priceDate.toLocal()),
                price: formatCurrency(_companyDetail.companyPrices[index].priceValue),
                diff: formatCurrency(_companyDetail.companyNetAssetValue! - _companyDetail.companyPrices[index].priceValue, true),
                riskColor: riskColor(_companyDetail.companyNetAssetValue!, _companyDetail.companyPrices[index].priceValue, _userInfo!.risk),
                dayDiff: (dayDiff == null ? "-" : formatCurrency(dayDiff, true)),
                dayDiffColor: dayDiffColor,
              );
            },
          ),
        )
      ],
    );
  }

  Widget _showCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            controller: _calendarScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 5,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("Current Price Comparison"),
                      const SizedBox(width: 10,),
                      CupertinoSwitch(
                        value: _showCurrentPriceComparison,
                        activeColor: accentColor,
                        onChanged: ((val) {
                          setState(() {
                            _showCurrentPriceComparison = val;
                          });
                        })
                      )
                    ],
                  ),
                  const SizedBox(height: 5,),
                  HeatGraph(
                    data: _heatGraphData,
                    userInfo: _userInfo!,
                    currentPrice: _companyDetail.companyNetAssetValue!,
                    enableDailyComparison: _showCurrentPriceComparison,
                    weekend: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SingleChildScrollView(
          controller: _graphScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: LineChart(
            data: _graphData,
            height: 250,
            watchlist: _watchlistDetail,
            dateOffset: (_graphData.length ~/ 10),
          ),
        )
      ],
    );
  }

  void _generateGraphData(CompanyDetailModel data) {
    double totalPrice = 0;
    int totalPriceData = 0;

    // clear the graph data
    _graphData.clear();

    // clear the heat map graph
    _heatGraphData.clear();

    _minPrice = double.maxFinite;
    _maxPrice = double.minPositive;

    // only get the 1st 64 data, since we will want to get the latest data
    for (PriceModel price in data.companyPrices) {
      // add the price to graph data
      _graphData.add(GraphData(date: price.priceDate.toLocal(), price: price.priceValue));

      // count for minimum, maximum, and average
      if(totalPriceData < 29) {
        if(_minPrice! > price.priceValue) {
          _minPrice = price.priceValue;
        }

        if(_maxPrice! < price.priceValue) {
          _maxPrice = price.priceValue;
        }

        totalPrice += price.priceValue;
        totalPriceData++;
      }

      // for heat map we will check if the heat map length is less than 98 or not?
      if (_heatGraphData.length <= 98) {
        _heatGraphData[price.priceDate.toLocal()] = GraphData(
          date: price.priceDate.toLocal(),
          price: price.priceValue
        );
      }
    }

    // sorted the graph data so the date will be sorted in ascending order
    _heatGraphData = sortedMap<DateTime, GraphData>(data: _heatGraphData);

    // add the current price which only in company
    _graphData.add(GraphData(date: data.companyLastUpdate!.toLocal(), price: data.companyNetAssetValue!));

    // check current price for minimum, maximum, and average
    if(_minPrice! > data.companyNetAssetValue!) {
      _minPrice = data.companyNetAssetValue!;
    }

    if(_maxPrice! < data.companyNetAssetValue!) {
      _maxPrice = data.companyNetAssetValue!;
    }

    totalPrice += data.companyNetAssetValue!;
    totalPriceData++;
    
    // compute average
    _avgPrice = totalPrice / totalPriceData;
    _numPrice = totalPriceData;

    // sort the temporary data
    _graphData.sort((a, b) {
      return a.date.compareTo(b.date);
    });
  }

  Future<bool> _getInitData() async {
    try {
      await Future.wait([
        _companyApi.getCompanyDetail(_companyData.companyId, _companyData.type).then((resp) {
          // copy the response to company detail data
          _companyDetail = resp;
          
          // generate map data
          _generateGraphData(resp);        
        }),
        
        _watchlistAPI.findDetail(_companyData.companyId).then((resp) {
          // if we got response then map it to the map, so later we can sent it
          // to the graph for rendering the time when we buy the share
          DateTime tempDate;
          for(WatchlistDetailListModel data in resp) {
            tempDate = data.watchlistDetailDate.toLocal();
            if (_watchlistDetail.containsKey(DateTime(tempDate.year, tempDate.month, tempDate.day))) {
              // if exists get the current value of the _watchlistDetails and put into _bitData
              _bitData.set(_watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)]!);
              // check whether this is buy or sell
              if (data.watchlistDetailShare >= 0) {
                _bitData[15] = 1;
              }
              else {
                _bitData[14] = 1;
              }
              _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = _bitData.toInt();
            }
            else {
              if (data.watchlistDetailShare >= 0) {
                _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 1;
              }
              else {
                _watchlistDetail[DateTime(tempDate.year, tempDate.month, tempDate.day)] = 2;
              }
            }
          }
        }),
      ]).then((_) async {
        // check if this crypto owned by user or not?
        _checkIfOwned();
      },).onError((error, stackTrace) {
        throw Exception('Error while get data from server');
      });
    }
    catch(error, stackTrace) {
      Log.error(
        message: 'Error when try to get the data from server',
        error: error,
        stackTrace: stackTrace,
      );
      throw 'Error when try to get the data from server';
    }

    return true;
  }

  Future<void> _checkIfOwned() async {
    // loop thru watchlist and check if this company is owned by the user or not?
    for(WatchlistListModel watchlist in _watchlists) {
      if (watchlist.watchlistCompanyId == _companyDetail.companyId) {
        _isOwned = true;
        return;
      }
    }
  }
}