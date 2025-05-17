import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';
import 'package:provider/provider.dart';

class InsightStockPERPerSectorSubPage extends StatefulWidget {
  const InsightStockPERPerSectorSubPage({super.key});

  @override
  State<InsightStockPERPerSectorSubPage> createState() => _InsightStockPERPerSectorSubPageState();
}

class _InsightStockPERPerSectorSubPageState extends State<InsightStockPERPerSectorSubPage> {
  late List<SectorNameModel> _sectorNameList;

  @override
  void initState() {
    super.initState();

    // get the per sector list data from shared preferences for the initial data
    _sectorNameList = CompanySharedPreferences.getSectorNameList();
  }

  @override
  Widget build(BuildContext context) {
    
    return Consumer<CompanyProvider>(
      builder: (context, companyProvider, child) {
        // get the sector name list from provider, so in case any changes on the
        // provide the page will be refreshed.
        _sectorNameList = (companyProvider.sectorNameList ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: Text(
                "PER Per Sector",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: double.infinity,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: List<Widget>.generate(_sectorNameList.length, (index) {             
                  InsightStockSubListArgs args = InsightStockSubListArgs(
                    type: 'PER',
                    sectorName: _sectorNameList[index].sectorName,
                    subName: _sectorNameList[index].sectorFriendlyname
                  );

                  return InkWell(
                    onTap: (() {
                      Navigator.pushNamed(context, '/insight/stock/per', arguments: args);
                    }),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: extendedColor,
                        border: Border.all(
                          color: extendedDark,
                          style: BorderStyle.solid,
                          width: 1.0,
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Globals.sectorIcon[_sectorNameList[index].sectorName.replaceAll('&amp;', '&')]!,
                            size: 25,
                            color: extendedLight,
                          ),
                          Center(
                            child: Text(
                              _sectorNameList[index].sectorFriendlyname,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: extendedLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}