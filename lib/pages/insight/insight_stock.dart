import 'package:flutter/material.dart';
import 'package:my_wealth/pages/insight/insight_stock_page/insight_stock_latest_split.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

enum InsightStockPageEnum {
  sectorSummary,
  topGainer,
  topLoser,
  perPerSector,
  stockNewlyListed,
  stockLatestDividend,
  latestStockSplit,
}

class InsightStockPage extends StatefulWidget {
  const InsightStockPage({super.key});

  @override
  State<InsightStockPage> createState() => _InsightStockPageState();
}

class _InsightStockPageState extends State<InsightStockPage> {
  final ScrollController _scrollController = ScrollController();
  final InsightAPI _insightAPI = InsightAPI();
  final CompanyAPI _companyAPI = CompanyAPI();

  late InsightStockPageEnum _selectedStockPage;


  @override
  void initState() {
    super.initState();

    // set the selected stock page to sector summary list
    _selectedStockPage = InsightStockPageEnum.sectorSummary;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: accentColor,
      onRefresh: (() async {
        // show loading screen
        LoadingScreen.instance().show(context: context);

        // refresh all the information
        await _refreshInformation(context).onError((error, stackTrace) {
          Log.error(
            message: 'Error getting insight stock information',
            error: error,
            stackTrace: stackTrace,
          );
        }).then((_) {
          // rebuild widget once finished
          setState(() {
            // just rebuild
          });
        }).whenComplete(() {
          // remove the loading screen
          LoadingScreen.instance().hide();
        });
      }),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ScrollSegmentedControl<InsightStockPageEnum>(
                data: const {
                  InsightStockPageEnum.sectorSummary: "Sector Summary",
                  InsightStockPageEnum.topGainer: "Top Gainer",
                  InsightStockPageEnum.topLoser: "Top Loser",
                  InsightStockPageEnum.perPerSector: "PER Per-Sector",
                  InsightStockPageEnum.stockNewlyListed: "Stock Newly Listed",
                  InsightStockPageEnum.stockLatestDividend: "Stock Latest Dividend",
                  InsightStockPageEnum.latestStockSplit: "Latest Stock Split",
                },
                onPress: ((value) {
                  setState(() {
                    _selectedStockPage = value;
                  });
                }),
              ),
              const SizedBox(height: 10,),
              _showPage(),
              const SizedBox(height: 20,),  
            ],
          ),
        ),
      ),
    );
  }

  Widget _showPage() {
    switch(_selectedStockPage) {
      case InsightStockPageEnum.sectorSummary:
        return InsightStockSectorSummarySubPage();
      case InsightStockPageEnum.topGainer:
        return InsightStockTopGainerSubPage(
          getCompanyDetailAndGo: ({required code}) async {
            await _getCompanyDetailAndGo(code: code);
          },
        );
      case InsightStockPageEnum.topLoser:
        return InsightStockTopLoserSubPage(
          getCompanyDetailAndGo: ({required code}) async {
            await _getCompanyDetailAndGo(code: code);
          },
        );
      case InsightStockPageEnum.perPerSector:
        return InsightStockPERPerSectorSubPage();
      case InsightStockPageEnum.stockNewlyListed:
        return InsightStockNewlyListedSubPage(
          getCompanyDetailAndGo: ({required code}) async {
            await _getCompanyDetailAndGo(code: code);
          },
        );
      case InsightStockPageEnum.stockLatestDividend:
        return InsightStockLatestDividendSubPage(
          getCompanyDetailAndGo: ({required code}) async {
            await _getCompanyDetailAndGo(code: code);
          },
        );
      case InsightStockPageEnum.latestStockSplit:
        return InsightStockLatestSplitSubPage(
          getCompanyDetailAndGo: ({required code}) async {
            await _getCompanyDetailAndGo(code: code);
          },
        );
    }
  }

  Future<void> _refreshInformation(BuildContext context) async {
    // refresh all the information
    await Future.wait([
      _insightAPI.getSectorSummary().then((resp) async {
        Log.success(message: "🔃 Refresh Sector Summary");
        await InsightSharedPreferences.setSectorSummaryList(sectorSummaryList: resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setSectorSummaryList(list: resp);
      }),
      _insightAPI.getTopWorseCompany(type: 'top').then((resp) async {
        Log.success(message: "🔃 Refresh Top Company Summary");
        await InsightSharedPreferences.setTopWorseCompanyList(
          type: 'top',
          topWorseList: resp
        );
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList(
          type: 'top',
          data: resp
        );
      }),
      _insightAPI.getTopWorseCompany(type: 'worse').then((resp) async {
        Log.success(message: "🔃 Refresh Worse Company Summary");
        await InsightSharedPreferences.setTopWorseCompanyList(
          type: 'worse',
          topWorseList: resp
        );
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setTopWorseCompanyList(
          type: 'worse',
          data: resp
        );
      }),
      _insightAPI.getStockNewListed().then((resp) async {
        Log.success(message: "🔃 Refresh Stock Newly Listed");
        await InsightSharedPreferences.setStockNewListed(stockNewList: resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockNewListed(data: resp);
      }),
      _insightAPI.getStockDividendList().then((resp) async {
        Log.success(message: "🔃 Refresh Stock Dividend List");
        await InsightSharedPreferences.setStockDividendList(stockDividendList: resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockDividendList(data: resp);
      }),
      _insightAPI.getStockSplitList().then((resp) async {
        Log.success(message: "🔃 Refresh Stock Split");
        await InsightSharedPreferences.setStockSplitList(stockDividendList: resp);
        if (!context.mounted) return;
        Provider.of<InsightProvider>(context, listen: false).setStockSplitList(data: resp);
      }),
    ]).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting stock insight information',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception("Error when get stock insight");
    });
  }

  Future<void> _getCompanyDetailAndGo({required String code}) async {
    // show loading screen first
    LoadingScreen.instance().show(context: context);

    // get the stock information based on code
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
      Log.error(
        message: 'Error getting company detail information',
        error: error,
        stackTrace: stackTrace,
      );

      if (mounted) {
        // show the error message
        ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: "Error when get company detail info"));
      }
    }).whenComplete(() {
      // remove the loading screen
      LoadingScreen.instance().hide();
    },);
  }
 }