import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/inisght_bandar_interest_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/company_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/dialog/show_info_dialog.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';

class InsightBandarAtlPage extends StatefulWidget {
  final String title;
  final String dialogTitle;
  final String dialogDescription;
  final List<BandarInterestAttributes> data;
  const InsightBandarAtlPage({Key? key, required this.title, required this.dialogTitle, required this.dialogDescription, required this.data}) : super(key: key);

  @override
  State<InsightBandarAtlPage> createState() => _InsightBandarAtlPageState();
}

class _InsightBandarAtlPageState extends State<InsightBandarAtlPage> {
  final ScrollController _scrollControllerATL = ScrollController();
  final CompanyAPI _companyAPI = CompanyAPI();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerATL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: (() async {
              await ShowInfoDialog(
                title: widget.dialogTitle,
                text: widget.dialogDescription,
                okayColor: secondaryLight,
              ).show(context);
            }),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: accentColor
                  ),
                ),
                const SizedBox(width: 5,),
                const Icon(
                  Ionicons.information_circle,
                  size: 15,
                  color: accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.builder(
              controller: _scrollControllerATL,
              itemCount: widget.data.length,
              itemBuilder: ((context, index) {
                return _item(data: widget.data[index]);            
              })
            ),
          )
        ],
      ),
    );
  }

  Widget _item({required BandarInterestAttributes data}) {
    return InkWell(
      onTap: (() async {
        showLoaderDialog(context);
        await _companyAPI.getCompanyByCode(data.code, 'saham').then((resp) {
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
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              style: BorderStyle.solid,
              width: 1.0,
            )
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: _text(
                    text: "(${data.code})",
                    color: secondaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: _text(
                    text: data.name
                  )
                ),
                const SizedBox(width: 5,),
                _text(text: formatIntWithNull(data.lastPrice)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "Volume", text: formatIntWithNull(int.tryParse(data.volume))),
                _column(title: "High", text: formatIntWithNull(data.adjustedHighPrice)),
                _column(title: "Low", text: formatIntWithNull(data.adjustedLowPrice)),
                _column(title: "Min30", text: formatIntWithNull(data.min30Price)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "MA5", text: formatIntWithNull(data.ma5), color: (data.ma5 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA8", text: formatIntWithNull(data.ma8), color: (data.ma8 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA13", text: formatIntWithNull(data.ma13), color: (data.ma13 < data.lastPrice ? secondaryColor : textPrimary)),
                _column(title: "MA20", text: formatIntWithNull(data.ma20), color: (data.ma20 < data.lastPrice ? secondaryColor : textPrimary)),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _column(title: "1 day", text: formatDecimalWithNull(data.oneDay, 100, 2), color: (data.oneDay < 0 ? secondaryColor : textPrimary)),
                _column(title: "1 week", text: formatDecimalWithNull(data.oneWeek, 100, 2), color: (data.oneWeek < 0 ? secondaryColor : textPrimary)),
                _column(title: "1 month", text: formatDecimalWithNull(data.oneMonth, 100, 2), color: (data.oneMonth < 0 ? secondaryColor : textPrimary)),
                _column(title: "ytd", text: formatDecimalWithNull(data.ytd, 100, 2), color: (data.ytd < 0 ? secondaryColor : textPrimary)),
              ],
            ),
            const SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }

  Widget _text({required String text, FontWeight? fontWeight, Color? color, double? fontSize}) {
    FontWeight currentFontWeight = (fontWeight ?? FontWeight.normal);
    Color currentColor = (color ?? textPrimary);
    double currentFontSize = (fontSize ?? 12);

    return Text(
      text,
      style: TextStyle(
        fontWeight: currentFontWeight,
        color: currentColor,
        fontSize: currentFontSize,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _column({required String title, required String text, Color? color}) {
    Color colorUse = (color ?? textPrimary);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _text(
              text: title,
              fontWeight: FontWeight.bold,
              color: extendedLight,
            ),
            const SizedBox(height: 5,),
            _text(
              text: text,
              color: colorUse
            ),
          ],
        ),
      ),
    );
  }
}