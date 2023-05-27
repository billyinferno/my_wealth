import 'package:flutter/material.dart';
import 'package:my_wealth/model/company/company_detail_model.dart';
import 'package:my_wealth/model/company/company_info_saham_price_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class AveragePriceChart extends StatefulWidget {
  final CompanyDetailModel company;
  final List<InfoSahamPriceModel> price;
  const AveragePriceChart({Key? key, required this.company, required this.price}) : super(key: key);

  @override
  State<AveragePriceChart> createState() => _AveragePriceChartState();
}

class _AveragePriceChartState extends State<AveragePriceChart> {
  late int _min;
  late int _max;
  late int _currentFlexLeft;
  late int _currentFlexRight;
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

  @override
  void initState() {
    _min = double.infinity as int;
    _max = double.negativeInfinity as int;
    _ma10 = 0;
    _ma20 = 0;
    _ma30 = 0;
    _avg = 0;
    
    _calculate();
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
          const Text(
            "Average Price Comparison",
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10,),
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
                      flex: _ma10FlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 13,
                      height: 23,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      flex: _ma10FlexRight,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: _ma20FlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 11,
                      height: 21,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21),
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: _ma20FlexRight,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: _ma30FlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 9,
                      height: 19,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      flex: _ma30FlexRight,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: _avgFlexLeft,
                      child: const SizedBox(),
                    ),
                    Container(
                      width: 7,
                      height: 17,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: secondaryColor,
                      ),
                    ),
                    Expanded(
                      flex: _avgFlexRight,
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
                      width: 5,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
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
          ),
          const SizedBox(height: 5,),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    formatIntWithNull(_min, false, false, 0),
                    style: const TextStyle(
                      fontSize: 10,
                      color: secondaryColor,
                    ),
                  ),
                  const Expanded(child: SizedBox(),),
                  Text(
                    formatIntWithNull(_max, false, false, 0),
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
                      flex: _ma10FlexLeft,
                      child: const SizedBox(),
                    ),
                    Text(
                      formatIntWithNull(_ma10, false, false, 0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                    ),
                    Expanded(
                      flex: _ma10FlexRight,
                      child: const SizedBox(),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: _ma20FlexLeft,
                      child: const SizedBox(),
                    ),
                    Text(
                      formatIntWithNull(_ma20, false, false, 0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      flex: _ma20FlexRight,
                      child: const SizedBox(),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: _ma30FlexLeft,
                      child: const SizedBox(),
                    ),
                    Text(
                      formatIntWithNull(_ma30, false, false, 0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                    Expanded(
                      flex: _ma30FlexRight,
                      child: const SizedBox(),
                    ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: _avgFlexLeft,
                      child: const SizedBox(),
                    ),
                    Text(
                      formatIntWithNull(_avg, false, false, 0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: secondaryColor,
                      ),
                    ),
                    Expanded(
                      flex: _avgFlexRight,
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
                    Text(
                      formatIntWithNull((widget.company.companyNetAssetValue == null ? 0 : widget.company.companyNetAssetValue!.toInt()), false, false, 0),
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
          const SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    const Text(
                      "MA10",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    const Text(
                      "MA20",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    const Text(
                      "MA30",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    const Text(
                      "AVG",
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryColor,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    const Text(
                      "Current",
                      style: TextStyle(
                        fontSize: 10,
                        color: textPrimary,
                      ),
                    )
                  ],
                ),
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