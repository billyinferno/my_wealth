import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class InsightBandarAtlPage extends StatefulWidget {
  final String title;
  final String dialogTitle;
  final String dialogDescription;
  final List<BandarInterestAttributes> data;
  const InsightBandarAtlPage({super.key, required this.title, required this.dialogTitle, required this.dialogDescription, required this.data});

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
      onTap: (() {
        _getCompanyDetailAndGo(code: data.code);
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
                _text(
                  text: "(${data.code})",
                  color: secondaryLight,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(width: 5,),
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
                ColumnInfo(
                  title: "Volume",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(int.tryParse(data.volume)),
                  valueSize: 15,
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "High",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.adjustedHighPrice),
                  valueSize: 15,
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "Low",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.adjustedLowPrice),
                  valueSize: 15,
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "Min30",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.min30Price),
                  valueSize: 15,
                ),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ColumnInfo(
                  title: "MA5",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.ma5),
                  valueSize: 15,
                  valueColor: (data.ma5 < data.lastPrice ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "MA8",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.adjustedHighPrice),
                  valueSize: 15,
                  valueColor: (data.ma8 < data.lastPrice ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "MA13",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.ma13),
                  valueSize: 15,
                  valueColor: (data.ma13 < data.lastPrice ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "MA20",
                  titleColor: Colors.grey,
                  value: formatIntWithNull(data.ma20),
                  valueSize: 15,
                  valueColor: (data.ma20 < data.lastPrice ? secondaryColor : textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 5,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ColumnInfo(
                  title: "1 Day",
                  titleColor: Colors.grey,
                  value: "${formatDecimalWithNull(data.oneDay, times: 100, decimal: 2,)}%",
                  valueSize: 15,
                  valueColor: (data.oneDay < 0 ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "1 Week",
                  titleColor: Colors.grey,
                  value: "${formatDecimalWithNull(data.oneWeek, times: 100, decimal: 2,)}%",
                  valueSize: 15,
                  valueColor: (data.oneWeek < 0 ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "1 Month",
                  titleColor: Colors.grey,
                  value: "${formatDecimalWithNull(data.oneMonth, times: 100, decimal: 2,)}%",
                  valueSize: 15,
                  valueColor: (data.oneMonth < 0 ? secondaryColor : textPrimary),
                ),
                const SizedBox(width: 5,),
                ColumnInfo(
                  title: "YTD",
                  titleColor: Colors.grey,
                  value: "${formatDecimalWithNull(data.ytd, times: 100, decimal: 2,)}%",
                  valueSize: 15,
                  valueColor: (data.ytd < 0 ? secondaryColor : textPrimary),
                ),
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
    double currentFontSize = (fontSize ?? 15);

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

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the company data and go
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
      // remove loading screen
      LoadingScreen.instance().hide();
    },);
  }
}