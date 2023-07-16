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

class StockCollectExpanded extends StatelessWidget {
  final InsightStockCollectModel data;
  const StockCollectExpanded({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CompanyAPI companyAPI = CompanyAPI();
    
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.15,
        children: <Widget>[
          SlidableAction(
            onPressed: ((BuildContext context) async {
              showLoaderDialog(context);
              await companyAPI.getCompanyByCode(data.code, 'saham').then((resp) {
                CompanyDetailArgs args = CompanyDetailArgs(
                  companyId: resp.companyId,
                  companyName: resp.companyName,
                  companyCode: data.code,
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(0),
        childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        backgroundColor: primaryColor,
        collapsedBackgroundColor: primaryColor,
        iconColor: primaryLight,
        collapsedIconColor: primaryLight,
        collapsedTextColor: textPrimary,
        textColor: textPrimary,
        title: _stockCollectHeader(),
        children: <Widget>[
          _stockCollectItemHeader(),
          ...List<Widget>.generate(data.data.length, (index) {
            return _stockCollectItem(
              item: data.data[index],
            );          
          })
        ],
      ),
    );
  }

  Widget _stockCollectHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          data.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5,),
        Text(
          "Total Broker ${data.data.length}",
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _itemSubText(
                header: "BUY (LOT)",
                headerColor: Colors.green,
                headerWeight: FontWeight.bold,
                value: formatIntWithNull(data.summaryTotalBuy, false, false, 0, false),
                subText: "${formatIntWithNull(data.summaryCountBuy, false, false, 0, false)} times",
              ),
              const SizedBox(width: 10,),
              _itemSubText(
                header: "SELL (LOT)",
                headerColor: secondaryColor,
                headerWeight: FontWeight.bold,
                value: formatIntWithNull(data.summaryTotalSell, false, false, 0, false),
                subText: "${formatIntWithNull(data.summaryCountSell, false, false, 0, false)} times",
              ),
              const SizedBox(width: 10,),
              _itemSubText(
                header: "LEFT (LOT)",
                headerColor: Colors.blue,
                headerWeight: FontWeight.bold,
                value: formatIntWithNull(data.summaryTotalLeft, false, false, 0, false),
                subText: "${formatDecimalWithNull(data.summaryTotalLeft / data.summaryTotalBuy, 100, 2)} %",
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _stockCollectItemHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        )
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                "ID",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          SizedBox(width: 5,),
          Expanded(
            child: Text(
              "BUY (LOT)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          SizedBox(width: 5,),
          Expanded(
            child: Text(
              "SELL (LOT)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          SizedBox(width: 5,),
          Expanded(
            child: Text(
              "LEFT (LOT)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockCollectItem({required InsightStockCollectItem item}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: primaryLight,
            width: 1.0,
            style: BorderStyle.solid,
          )
        )
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                item.brokerSummaryId,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5,),
          _itemSubItem(value: [
            formatIntWithNull(item.totalBuy, false, false, 0, false),
            "${formatIntWithNull(item.countBuy, false, false, 0, false)} times",
          ]),
          const SizedBox(width: 5,),
          _itemSubItem(value: [
            formatIntWithNull(item.totalSell, false, false, 0, false),
            "${formatIntWithNull(item.countSell, false, false, 0, false)} times",
          ]),
          const SizedBox(width: 5,),
          _itemSubItem(value: [
            formatIntWithNull(item.totalLeft, false, false, 0, false),
            "${formatDecimalWithNull(item.totalPercentage, 100, 2)} %",
          ]),
        ],
      ),
    );
  }

  Widget _itemSubText({
    required String header,
    Color? headerColor,
    FontWeight? headerWeight,
    required String value,
    String? subText
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: primaryLight,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              ),
            ),
            child: Text(
              header,
              style: TextStyle(
                fontSize: 12,
                color: (headerColor ?? textPrimary),
                fontWeight: (headerWeight ?? FontWeight.normal)
              ),
            )
          ),
          const SizedBox(height: 5,),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2,),
          Visibility(
            visible: (subText != null),
            child: Text(
              (subText ?? ''),
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _itemSubItem({required List<String> value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(value.length, (index) {
          return Text(
            value[index],
            style: const TextStyle(
              fontSize: 10,
            ),
          );
        }),
      ),
    );
  }
}