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
import 'package:my_wealth/widgets/list/my_table_view.dart';

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
          MyTableView(data: [
            MyTableItem(
              title: "BUY (LOT)",
              color: Colors.green[900]!,
              content: <String>[
                formatIntWithNull(widget.data.summaryTotalBuy, false, false, 0, false),
                "${formatIntWithNull(widget.data.summaryCountBuy, false, false, 0, false)} times",
              ]
            ),
            MyTableItem(
              title: "SELL (LOT)",
              color: secondaryDark,
              content: <String>[
                formatIntWithNull(widget.data.summaryTotalSell, false, false, 0, false),
                "${formatIntWithNull(widget.data.summaryCountSell, false, false, 0, false)} times",
              ]
            ),
            MyTableItem(
              title: "LEFT (LOT)",
              color: Colors.blue[800]!,
              content: <String>[
                formatIntWithNull(widget.data.summaryTotalLeft, false, false, 0, false),
                "${formatDecimalWithNull(widget.data.summaryTotalLeft / widget.data.summaryTotalBuy, 100, 2)} %",
              ]
            ),
          ]),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange,
        border: Border.all(
          color: primaryLight,
          style: BorderStyle.solid,
          width: 1.0,
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 40,
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
            child: Container(
              color: primaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  MyTableView(data: [
                    MyTableItem(
                      title: "BUY (LOT)",
                      color: Colors.green[600]!,
                      content: <String>[
                        formatIntWithNull(widget.data.data[index].totalBuy, false, false, 0, false),
                        "${formatIntWithNull(widget.data.data[index].countBuy, false, false, 0, false)} times",
                      ]
                    ),
                    MyTableItem(
                      title: "SELL (LOT)",
                      color: secondaryColor,
                      content: <String>[
                        formatIntWithNull(widget.data.data[index].totalSell, false, false, 0, false),
                        "${formatIntWithNull(widget.data.data[index].countSell, false, false, 0, false)} times",
                      ]
                    ),
                    MyTableItem(
                      title: "LEFT (LOT)",
                      color: Colors.blue[400]!,
                      content: <String>[
                        formatIntWithNull(widget.data.data[index].totalLeft, false, false, 0, false),
                        "${formatDecimalWithNull(widget.data.data[index].totalPercentage, 100, 2)} %",
                      ]
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
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
}