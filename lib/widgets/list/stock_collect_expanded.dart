import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/insight/insight_stock_collect_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';

class StockCollectExpanded extends StatefulWidget {
  final InsightStockCollectModel data;
  const StockCollectExpanded({Key? key, required this.data}) : super(key: key);

  @override
  State<StockCollectExpanded> createState() => _StockCollectExpandedState();
}

class _StockCollectExpandedState extends State<StockCollectExpanded> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final TextStyle headerStyle = const TextStyle(
    fontSize: 10,
  );
  final BorderSide borderStyle = const BorderSide(
    color: primaryLight,
    style: BorderStyle.solid,
    width: 1.0,
  );

  late bool isOpen;

  @override
  void initState() {
    // initialize the variable
    isOpen = false;

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: primaryLight,
          style: BorderStyle.solid,
          width: 1.0,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.15,
              children: <Widget>[
                SlidableAction(
                  onPressed: ((BuildContext context) async {
                    showLoaderDialog(context);
                    await _companyAPI.getCompanyByCode(widget.data.code, 'saham').then((resp) {
                      CompanyDetailArgs args = CompanyDetailArgs(
                        companyId: resp.companyId,
                        companyName: resp.companyName,
                        companyCode: widget.data.code,
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
                  icon: Ionicons.business_outline,
                  backgroundColor: primaryColor,
                  foregroundColor: extendedLight,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.data.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Text(
                    "Total Broker ${widget.data.data.length}",
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5,),
          _itemWithHeader(
            countBuy: widget.data.summaryCountBuy,
            countSell: widget.data.summaryCountSell,
            totalBuy: widget.data.summaryTotalBuy,
            totalSell: widget.data.summaryTotalSell,
            totalLeft: widget.data.summaryTotalLeft,
          ),
          InkWell(
            onTap: (() {
              setState(() {
                isOpen = !isOpen;
              });
            }),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: primaryDark,
                border: Border(
                  left: borderStyle,
                  right: borderStyle,
                  bottom: borderStyle,
                )
              ),
              width: double.infinity,
              child: (isOpen ? _showDataList() : _showArrowIcon()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showDataList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        ...List<Widget>.generate(widget.data.data.length, (index) {
          return _itemList(index: index);
        }),
        const SizedBox(height: 5,),
        const Center(
          child: Icon(
            Ionicons.caret_up,
            color: textPrimary,
            size: 11,
          ),
        ),
      ],
    );
  }

  Widget _itemList({required int index}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange[900],
            border: Border(
              left: borderStyle,
              top: borderStyle,
              bottom: borderStyle,
            )
          ),
          child: Center(
            child: Text(
              widget.data.data[index].brokerSummaryId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: _itemWithHeader(
            countBuy: widget.data.data[index].countBuy,
            countSell: widget.data.data[index].countSell,
            totalBuy: widget.data.data[index].totalBuy,
            totalSell: widget.data.data[index].totalSell,
            totalLeft: widget.data.data[index].totalLeft,
          ),
        ),
      ],
    );
  }

  Widget _showArrowIcon() {
    return const Center(
      child: Icon(
        Ionicons.caret_down,
        color: textPrimary,
        size: 11,
      ),
    );
  }

  Widget _itemWithHeader({
    required int totalBuy,
    required int countBuy,
    required int totalSell,
    required int countSell,
    required int totalLeft
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: borderStyle,
                top: borderStyle,
                bottom: borderStyle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  color: Colors.green[900],
                  child: Center(
                    child: Text(
                      "BUY (LOT)",
                      style: headerStyle.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      formatIntWithNull(
                        totalBuy,
                        false,
                        false,
                        0,
                        false
                      ),
                      style: headerStyle,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      "${formatIntWithNull(
                        countBuy,
                        false,
                        false,
                        0,
                        false
                      )} times",
                      style: headerStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: primaryLight,
                style: BorderStyle.solid,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  color: Colors.red[900],
                  child: Center(
                    child: Text(
                      "SELL (LOT)",
                      style: headerStyle.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      formatIntWithNull(
                        totalSell,
                        false,
                        false,
                        0,
                        false
                      ),
                      style: headerStyle,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      "${formatIntWithNull(
                        countSell,
                        false,
                        false,
                        0,
                        false
                      )} times",
                      style: headerStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: borderStyle,
                top: borderStyle,
                bottom: borderStyle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  color: Colors.blue[800],
                  child: Center(
                    child: Text(
                      "LEFT (LOT)",
                      style: headerStyle.copyWith(
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      formatIntWithNull(
                        totalLeft,
                        false,
                        false,
                        0,
                        false
                      ),
                      style: headerStyle,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  child: Center(
                    child: Text(
                      "${formatDecimalWithNull(
                        totalLeft / totalBuy,
                        100,
                        2)} %",
                      style: headerStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}