import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/model/broker/broker_summary_accumulation_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/widgets/list/expanded_section.dart';

class BrokerSummaryDistributionChart extends StatefulWidget {
  final List<BrokerSummaryAccumulationModel> data;
  const BrokerSummaryDistributionChart({Key? key, required this.data}) : super(key: key);

  @override
  State<BrokerSummaryDistributionChart> createState() => _BrokerSummaryDistributionChartState();
}

class _BrokerSummaryDistributionChartState extends State<BrokerSummaryDistributionChart> {
  final DateFormat _df = DateFormat("dd/MM/yyyy");
  
  late int _brokerAccumulationLeft;
  late int _brokerAccumulationRight;

  int _accumVersion = 1;
  bool _enableV2 = true;
  bool _showBrokerAccumulationList = false;

  @override
  void initState() {
    // initialize all the variable needed for the widget
    _accumVersion = 1;

    // check if we need to enable v2 or not?
    // we can do this by checking if the length of the widget.data is more than 1
    // since v2 will use index-1.
    if (widget.data.length < 2) {
      _enableV2 = false;
      _accumVersion = 0; // force  to v1

      // defaulted left and right as 0
      _brokerAccumulationLeft = 0;
      _brokerAccumulationRight = 0;
    }
    else {
      // v2 is enable, we can calculate this data
      // calculate the _brokerAccumulationLeft and Right
      _calculateBrokerAccumulationRatio(widget.data[_accumVersion]);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          color: primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: (() async {
                  String v1Info = "This will compare the last 3 days of NET broker accumulation, compare to the 7 days average summary period (after the 3 days, so in total we use 10-days of broker data) to see the accumulation trends.\n\nIt will use the company last update date as the current date.";
                  String v2Info = "This will perform comparison for each day to see the movement of the broker, and summarize it to see whether in 10 day the broker is mostly buy or sell, and it will compare with the average of the net broker transaction for 10 day.\n\nIt will use the company last update date as the current date.";
                  await ShowInfoDialog(
                    title: "Broker Accumulation",
                    text: (_accumVersion == 0 ? v1Info : v2Info),
                    okayColor: accentColor
                  ).show(context);
                }),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Broker Accumulation",
                      style: TextStyle(
                        color: secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5,),
                    const Icon(
                      Ionicons.information_circle,
                      color: accentLight,
                      size: 15,
                    ),
                    const Expanded(child: SizedBox(),),
                    const Text(
                      "v1/v2",
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 2,),
                    SizedBox(
                      width: 50,
                      height: 25,
                      child: FittedBox(
                        child: CupertinoSwitch(
                          value: (_accumVersion == 1),
                          activeColor: accentColor,
                          onChanged: ((_enableV2 == false ? null : (value) {
                            if (_accumVersion == 0) {
                              _accumVersion = 1;
                            }
                            else {
                              _accumVersion = 0;
                            }
                                                  
                            setState(() {
                              _calculateBrokerAccumulationRatio(widget.data[_accumVersion]);
                            });
                          })),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              InkWell(
                onTap: (() {
                  setState(() {
                    _showBrokerAccumulationList = !_showBrokerAccumulationList;
                  });
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
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
                              const Expanded(child: SizedBox(),),
                              Container(
                                width: 2,
                                height: 5,
                                color: primaryColor,
                              ),
                              const Expanded(child: SizedBox(),),
                              Container(
                                width: 2,
                                height: 5,
                                color: primaryColor,
                              ),
                              const Expanded(child: SizedBox(),),
                              Container(
                                width: 2,
                                height: 5,
                                color: primaryColor,
                              ),
                              const Expanded(child: SizedBox(),),
                              Container(
                                width: 2,
                                height: 5,
                                color: primaryColor,
                              ),
                              const Expanded(child: SizedBox(),),
                              Container(
                                width: 2,
                                height: 5,
                                color: primaryColor,
                              ),
                              const Expanded(child: SizedBox(),),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: _brokerAccumulationLeft,
                                child: const SizedBox()
                              ),
                              Container(
                                height: 15,
                                width: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)
                                ),
                              ),
                              Expanded(
                                flex: _brokerAccumulationRight,
                                child: const SizedBox()
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(
                          width: 75,
                          child: Text(
                            "Dist",
                            style: TextStyle(
                              fontSize: 10,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: Icon(
                              (_showBrokerAccumulationList ? Ionicons.chevron_up : Ionicons.chevron_down),
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 75,
                          child: Text(
                            "Accum",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: _showBrokerAccumulationList,
          child: ExpandedSection(
            expand: _showBrokerAccumulationList,
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 80,
                        color: primaryDark,
                        padding: const EdgeInsets.all(2.5),
                        child: const Text(
                          "DATE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: primaryDark,
                          padding: const EdgeInsets.all(2.5),
                          child: const Text(
                            "BUY LOT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: primaryDark,
                          padding: const EdgeInsets.all(2.5),
                          child: const Text(
                            "SELL LOT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: primaryDark,
                          padding: const EdgeInsets.all(2.5),
                          child: const Text(
                            "DIFF",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...List<Widget>.generate(widget.data.length > 1 ? widget.data[1].brokerSummaryData.length : 0, (index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 80,
                          padding: const EdgeInsets.all(2.5),
                          child: Text(
                            _df.format(widget.data[1].brokerSummaryData[index].brokerSummaryDate),
                            style: const TextStyle(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            child: Text(
                              formatIntWithNull(widget.data[1].brokerSummaryData[index].brokerSummaryBuyLot, false, true, 2),
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            child: Text(
                              formatIntWithNull(widget.data[1].brokerSummaryData[index].brokerSummarySellLot, false, true, 2),
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(2.5),
                            child: Text(
                              formatIntWithNull(widget.data[1].brokerSummaryData[index].brokerSummaryLot, false, true, 2),
                              style: TextStyle(
                                fontSize: 10,
                                color: (widget.data[1].brokerSummaryData[index].brokerSummaryLot == 0 ? textPrimary : (widget.data[1].brokerSummaryData[index].brokerSummaryLot < 0) ? secondaryColor : Colors.green),
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            )
          ),
        ),
      ],
    );
  }

  void _calculateBrokerAccumulationRatio(BrokerSummaryAccumulationModel data) {
    // check if _brokerSummaryAccumulation.brokerSummaryAvgLot == 0, if so then let left and right as 1
    if (data.brokerSummaryAvgLot == 0) {
      // use the current value as the guide to either go left or right
      _brokerAccumulationLeft = (1 + (data.brokerSummaryAvgCurrentLot * 10)).abs().toInt();
      _brokerAccumulationRight = (1 - (data.brokerSummaryAvgCurrentLot * 10)).abs().toInt();
    }
    else {
      // check whether the brokerSummaryAvgLot is < 0 or > 0
      if (data.brokerSummaryAvgLot < 0) {
        // means that the average 7 days before this mostly sell
        // so, we check whether in 3 days also sell? If so then we knew that it's a distribution
        if (data.brokerSummaryAvgCurrentLot == 0) {
          // it's a distribution continuation that probably will lead to positive (side ways usually)
          // for this we just need to use the current summary average as vector
          _brokerAccumulationLeft = 100;
          _brokerAccumulationRight = 100 + (data.brokerSummaryAvgLot * 100).abs().toInt();
        }
        else if (data.brokerSummaryAvgCurrentLot < 0) {
          // this is a distribution.
          // for this we can just check how much distribution did it have by just divide the current and the average
          // and use that as add vector to the right side. We need to be a bit harsh on the distribution where all the value of
          // current and summary average is below 0, because it means that all people want to offload their share.
          // so we need to see how much is the left vector.
          _brokerAccumulationLeft = (data.brokerSummaryAvgLot).abs().toInt();
          _brokerAccumulationRight = (data.brokerSummaryAvgCurrentLot).abs().toInt();
        }
        else {
          // this is an accumulation after distribution
          // for this we can calculate how times increment needed to get current average from the summary and add that as vector
          // to the left side
          _brokerAccumulationLeft = 100 + (((data.brokerSummaryAvgCurrentLot + data.brokerSummaryAvgLot.abs()) / data.brokerSummaryAvgLot.abs()) * 100).toInt();
          _brokerAccumulationRight = 100;
        }
      }
      else {
        // means the average 7 days before this mostly buy
        // now check if in 3 days also buy or sell?
        if (data.brokerSummaryAvgCurrentLot == 0) {
          // seems like people try to offload the share as suddenly the buy is declined
          // it means that probably the distribution will be happen soon, or the price already not that sexy
          // so people tends to choose other stock.
          // for this we can just assume that distribution will occurs soon, so use the summary average as vector to add on the right side.
          _brokerAccumulationLeft = 100;
          _brokerAccumulationRight = 100 + (data.brokerSummaryAvgLot * 100).toInt();
        }
        else if (data.brokerSummaryAvgCurrentLot < 0) {
          // this is a distribution.
          // for this we can just check how much distribution did it have by just divide the current and the average
          // and use that as add vector to the right side
          _brokerAccumulationLeft = 100;
          _brokerAccumulationRight = 100 + (((data.brokerSummaryAvgCurrentLot - data.brokerSummaryAvgLot).abs() / data.brokerSummaryAvgLot) * 100).toInt();
        }
        else {
          // this is an ongoing accumulation, means that for 7 days all the average is mostly buy
          // if like this we can just see how much difference the accumulation compare to the previous one, if lesser by a lot it will make
          // it as if there are distribution going on soon, if it still goes strong as per the average, then probably it was a long
          // run of accumulation due the stock price is still good enough
          _brokerAccumulationLeft = (data.brokerSummaryAvgCurrentLot).toInt();
          _brokerAccumulationRight = (data.brokerSummaryAvgLot).toInt();
        }
      }
    }
  }
}