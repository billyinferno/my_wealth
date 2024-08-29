import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

enum ChartType { avg, ma10, ma20, ma30 }

class AveragePriceChart extends StatefulWidget {
  final CompanyDetailModel company;
  final List<InfoSahamPriceModel> price;
  const AveragePriceChart({super.key, required this.company, required this.price});

  @override
  State<AveragePriceChart> createState() => _AveragePriceChartState();
}

class _AveragePriceChartState extends State<AveragePriceChart> {
  late int _min;
  late int _max;
  late int _currentFlexLeft;
  late int _currentFlexRight;
  late int _selectedValue;
  late int _selectedFlexLeft;
  late int _selectedFlexRight;
  late int _ma10;
  late int _ma10FlexLeft;
  late int _ma10FlexRight;
  late int _ma20;
  late int _ma20FlexLeft;
  late int _ma20FlexRight;
  late int _ma30;
  late int _ma30FlexLeft;
  late int _ma30FlexRight;
  late int _avg;
  late int _avgFlexLeft;
  late int _avgFlexRight;
  late ChartType _currentSegment;

  final Map<ChartType, Color> _chartColors = {
    ChartType.avg: Colors.orange,
    ChartType.ma10: Colors.purple,
    ChartType.ma20: const Color(0xff40826d),
    ChartType.ma30: const Color(0xff007ba7),
  };

  final Map<ChartType, String> _chartName = {
    ChartType.avg: "Average",
    ChartType.ma10: "MA10",
    ChartType.ma20: "MA20",
    ChartType.ma30: "MA30",
  };

  @override
  void initState() {
    _min = double.maxFinite.toInt();
    _max = _min * (-1);
    _ma10 = 0;
    _ma20 = 0;
    _ma30 = 0;
    _avg = 0;
    
    _calculate();
    _currentSegment = ChartType.avg;
    _selectedValue = _avg;
    _selectedFlexLeft = _avgFlexLeft;
    _selectedFlexRight = _avgFlexRight;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Price Comparison",
                style: TextStyle(
                  color: secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoSegmentedControl<ChartType>(
                  selectedColor: _chartColors[_currentSegment],
                  groupValue: _currentSegment,
                  onValueChanged: (ChartType value) {
                    setState(() {
                      switch(value) {
                        case ChartType.avg:
                          _selectedValue = _avg;
                          _selectedFlexLeft = _avgFlexLeft;
                          _selectedFlexRight = _avgFlexRight;
                          break;
                        case ChartType.ma10:
                          _selectedValue = _ma10;
                          _selectedFlexLeft = _ma10FlexLeft;
                          _selectedFlexRight = _ma10FlexRight;
                          break;
                        case ChartType.ma20:
                          _selectedValue = _ma20;
                          _selectedFlexLeft = _ma20FlexLeft;
                          _selectedFlexRight = _ma20FlexRight;
                          break;
                        case ChartType.ma30:
                          _selectedValue = _ma30;
                          _selectedFlexLeft = _ma30FlexLeft;
                          _selectedFlexRight = _ma30FlexRight;
                          break;
                        default:
                          _selectedValue = _avg;
                          _selectedFlexLeft = _avgFlexLeft;
                          _selectedFlexRight = _avgFlexRight;
                          break;
                      }
                      _currentSegment = value;
                    });
                  },
                  children: const<ChartType, Widget> {
                    ChartType.avg: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "AVG",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ChartType.ma10: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "MA10",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ChartType.ma20: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "MA20",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ChartType.ma30: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        "MA30",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  }
                ),
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: _selectedFlexLeft,
                child: const SizedBox(),
              ),
              Text(
                "${_chartName[_currentSegment]} Price ${formatIntWithNull(
                  _selectedValue,
                  showDecimal: false,
                  decimalNum: 0,
                )}",
                style: TextStyle(
                  fontSize: 10,
                  color: _chartColors[_currentSegment],
                ),
              ),
              Expanded(
                flex: _selectedFlexRight,
                child: const SizedBox(),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: _selectedFlexLeft,
                child: const SizedBox(),
              ),
              SizedBox(
                height: 25,
                width: 15,
                child: Center(
                  child: Container(
                    height: 25,
                    width: 1,
                    color: _chartColors[_currentSegment],
                  ),
                ),
              ),
              Expanded(
                flex: _selectedFlexRight,
                child: const SizedBox(),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        secondaryColor,
                        Colors.green,
                      ]
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: _selectedFlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: _chartColors[_currentSegment],
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Expanded(
                      flex: _selectedFlexRight,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: _currentFlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: textPrimary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    Expanded(
                      flex: _currentFlexRight,
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    formatIntWithNull(
                      _min,
                      showDecimal: false,
                      decimalNum: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: secondaryColor,
                    ),
                  ),
                  Text(
                    formatIntWithNull(
                      _max,
                      showDecimal: false,
                      decimalNum: 0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: _currentFlexLeft,
                    child: const SizedBox(),
                  ),
                  SizedBox(
                    height: 25,
                    width: 15,
                    child: Center(
                      child: Container(
                        height: 25,
                        width: 1,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: _currentFlexRight,
                    child: const SizedBox(),
                  ),
                ],
              ),  
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: _currentFlexLeft,
                child: const SizedBox(),
              ),
              Text(
                "Current Price ${formatIntWithNull(
                  (widget.company.companyNetAssetValue == null ? 0 : widget.company.companyNetAssetValue!.toInt()),
                  showDecimal: false,
                  decimalNum: 0,
                )}",
                style: const TextStyle(
                  fontSize: 10,
                  color: textPrimary,
                ),
              ),
              Expanded(
                flex: _currentFlexRight,
                child: const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _calculate() {
    int num = 0;
    
    // init the flex value
    _currentFlexLeft = 1;
    _currentFlexRight = 1;
    _avgFlexLeft = 1;
    _avgFlexRight = 1;
    _ma10FlexLeft = 1;
    _ma10FlexRight = 1;
    _ma20FlexLeft = 1;
    _ma20FlexRight = 1;
    _ma30FlexLeft = 1;
    _ma30FlexRight = 1;

    for(InfoSahamPriceModel price in widget.price) {
      if (_min > price.lastPrice) {
        _min = price.lastPrice;
      }
      if (_max < price.lastPrice) {
        _max = price.lastPrice;
      }

      // add num
      num = num + 1;

      // count for SMA
      if (num <= 10) {
        _ma10 += price.lastPrice;
      }
      if (num <= 20) {
        _ma20 += price.lastPrice;
      }
      if (num <= 30) {
        _ma30 += price.lastPrice;
      }

      // adding the average
      _avg += price.lastPrice;
    }

    // get the SMA
    // MA10
    if (widget.price.length >= 10) {
      _ma10 = _ma10 ~/ 10;
    }
    else {
      _ma10 = _ma10 ~/ widget.price.length;
    }
    // MA20
    if (widget.price.length >= 20) {
      _ma20 = _ma20 ~/ 20;
    }
    else {
      _ma20 = _ma20 ~/ widget.price.length;
    }
    // MA30
    if (widget.price.length >= 30) {
      _ma30 = _ma30 ~/ 30;
    }
    else {
      _ma30 = _ma30 ~/ widget.price.length;
    }

    // if _max == _min
    if (_max == _min) {
      // make _min into 0, so we will not gen NaN when we calculate the flex
      // for the average price below
      _min = 0;
    }

    // calculate the flex for current price
    _currentFlexLeft = (((widget.company.companyNetAssetValue! - _min) / (_max - _min)) * 100).toInt();
    _currentFlexRight = (((_max - widget.company.companyNetAssetValue!) / (_max - _min)) * 100).toInt();

    // calculate the flex for SMA
    // MA10
    _ma10FlexLeft = (((_ma10 - _min) / (_max - _min)) * 100).toInt();
    _ma10FlexRight = (((_max - _ma10) / (_max - _min)) * 100).toInt();
    // MA20
    _ma20FlexLeft = (((_ma20 - _min) / (_max - _min)) * 100).toInt();
    _ma20FlexRight = (((_max - _ma20) / (_max - _min)) * 100).toInt();
    // MA30
    _ma30FlexLeft = (((_ma30 - _min) / (_max - _min)) * 100).toInt();
    _ma30FlexRight = (((_max - _ma30) / (_max - _min)) * 100).toInt();

    // get the average
    _avg = _avg ~/ widget.price.length;
    // calculate the flex for average price
    _avgFlexLeft = (((_avg - _min) / (_max - _min)) * 100).toInt();
    _avgFlexRight = (((_max - _avg) / (_max - _min)) * 100).toInt();
  }
}