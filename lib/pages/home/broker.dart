import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:my_wealth/_index.g.dart';

class BrokerPage extends StatefulWidget {
  const BrokerPage({super.key});

  @override
  State<BrokerPage> createState() => _BrokerPageState();
}

class _BrokerPageState extends State<BrokerPage> {
  final ScrollController _scrollController = ScrollController();
  final BrokerAPI _brokerAPI = BrokerAPI();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _filterList = {};

  late List<BrokerModel> _brokerList;
  late List<BrokerModel> _filterBrokerList;
  late String _filterMode;
  late SortBoxType _filterSort;
  late DateTime _maxBrokerDate;

  @override
  void initState() {
    super.initState();

    _brokerList = BrokerSharedPreferences.getBrokerList();
    _filterBrokerList = BrokerSharedPreferences.getBrokerList();
    _maxBrokerDate = (BrokerSharedPreferences.getBrokerMaxDate() ?? DateTime.now());

    // list all the filter that we want to put here
    _filterList["CD"] = "Code";
    _filterList["VL"] = "Volume";
    _filterList["VA"] = "Value";
    _filterList["FR"] = "Frequency";

    // default filter mode to Code and ASC
    _filterMode = "CD";
    _filterSort = SortBoxType.ascending;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BrokerProvider>(
      builder: ((context, brokerProvider, child) {
        _brokerList = brokerProvider.brokerList!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: primaryDark,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
              child: CupertinoSearchTextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: '--apple-system',
                ),
                onChanged: ((search) {
                  // we will filter the broker list and set the result to the filter list
                  _filterBroker(search);
                }),
              ),
            ),
            SortBox(
              filterList: _filterList,
              initialFilter: _filterMode,
              filterSort: _filterSort,
              onChanged: (filter, sort) {
                _filterMode = filter;
                _filterSort = sort;
                _sortedBrokerList();
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: (() async {
                  await _refreshBroker().then((value) {
                    Log.success(message: "🔃 Refresh Broker");
                    // rebuild the state
                    setState(() {
                    });
                  }).onError((error, stackTrace) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                    }
                  }).whenComplete(() {  
                    // once finished just rebuild the widget
                    setState(() {
                      // just rebuild
                    });
                  },);
                }),
                color: accentColor,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: List.generate(_filterBrokerList.length, (index) {
                    return InkWell(
                      onTap: (() {
                        BrokerDetailArgs args = BrokerDetailArgs(
                          brokerFirmID: _filterBrokerList[index].brokerFirmId
                        );
                        Navigator.pushNamed(context, '/broker/detail', arguments: args);
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: primaryLight, style: BorderStyle.solid, width: 1.0))
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _filterBrokerList[index].brokerFirmId,
                                  style: TextStyle(
                                    color: (
                                      _filterBrokerList[index].brokerDate.isBeforeDate(date: _maxBrokerDate) ?
                                      secondaryColor :
                                      accentColor
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Expanded(
                                  child: Text(
                                    _filterBrokerList[index].brokerFirmName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Visibility(
                                  visible: (_filterBrokerList[index].brokerDate.isBeforeDate(date: _maxBrokerDate)),
                                  child: const SizedBox(width: 10,),
                                ),
                                Visibility(
                                  visible: (_filterBrokerList[index].brokerDate.isBeforeDate(date: _maxBrokerDate)),
                                  child: const Icon(
                                    Ionicons.warning,
                                    color: secondaryColor,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _informationText(
                                  flex: 2,
                                  text: "Date",
                                  value: Globals.dfddMMyyyy.formatLocal(
                                    _filterBrokerList[index].brokerDate
                                  )
                                ),
                                _informationText(
                                  text: "Volume",
                                  value: formatIntWithNull(
                                    _filterBrokerList[index].brokerVolume,
                                    checkThousand: true,
                                  )
                                ),
                                _informationText(
                                  text: "Value",
                                  value: formatIntWithNull(
                                    _filterBrokerList[index].brokerValue,
                                    checkThousand: true,
                                  )
                                ),
                                _informationText(
                                  text: "Frequency",
                                  value: formatIntWithNull(
                                    _filterBrokerList[index].brokerFrequency,
                                    showDecimal: false
                                  )
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _refreshBroker() async {
    // show loading screen
    LoadingScreen.instance().show(context: context);

    // get the broker list
    await _brokerAPI.getBroker().then((resp) async {
      // set the shared preferences and provider for index
      await BrokerSharedPreferences.setBrokerList(brokerList: resp);

      // announce the broker in the provider
      await _updateBrokerProvider(brokerList: resp);
    }).onError((error, stackTrace) {
      // hide loading screen when got error
      LoadingScreen.instance().hide();

      // throw exception
      Log.error(
        message: "Error when refresh broker",
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(error.toString());
    });

    // hide loading screen
    LoadingScreen.instance().hide();
  }

  Future<void> _updateBrokerProvider({
    required List<BrokerModel> brokerList
  }) async {
    Provider.of<BrokerProvider>(context, listen: false).setBrokerList(
      brokerListData: brokerList
    );
  }

  Widget _informationText({
    int? flex,
    required String text,
    Color textColor = textPrimary,
    required String value,
    Color valueColor = textPrimary,
  }) {
    int flexNum = (flex ?? 1);

    return Expanded(
      flex: flexNum,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: valueColor,
            ),
          )
        ],
      ),
    );
  }

  void _filterBroker(String filterText) {
    List<BrokerModel> result = [];

    // check if filter text empty or not?
    // if empty just return the broker list, avoid the loop
    if (filterText.isEmpty) {
      result = _brokerList;
    }
    else {
      // loop thru broker list
      for (BrokerModel broker in _brokerList) {
        // check if the code or name contains filter text or not?
        if (
          broker.brokerFirmId.toLowerCase().contains(filterText.toLowerCase()) ||
          broker.brokerFirmName.toLowerCase().contains(filterText.toLowerCase())
        ) {
          result.add(broker);
        }
      }
    }

    // at the end set the filter broker list with result
    setState(() {
      _filterBrokerList = result;
      _sortedBrokerList();
    });
  }

  void _sortedBrokerList() {
    List<BrokerModel> tempFilter = List<BrokerModel>.from(_filterBrokerList);
    switch(_filterMode) {
      case "VL":
        tempFilter.sort(((a, b) => (a.brokerVolume).compareTo((b.brokerVolume))));
        break;
      case "VA":
        tempFilter.sort(((a, b) => (a.brokerValue).compareTo((b.brokerValue))));
        break;
      case "FR":
        tempFilter.sort(((a, b) => (a.brokerFrequency ).compareTo((b.brokerFrequency))));
        break;
      default:
        tempFilter.sort(((a, b) => (a.brokerFirmId).compareTo((b.brokerFirmId))));
        break;
    }

    // check the filter type
    if (_filterSort == SortBoxType.ascending) {
      _filterBrokerList = List<BrokerModel>.from(tempFilter);
    }
    else {
      _filterBrokerList = List<BrokerModel>.from(tempFilter.reversed);
    }
  }
}