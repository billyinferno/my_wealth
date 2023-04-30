import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/api/broker_api.dart';
import 'package:my_wealth/model/broker/broker_model.dart';
import 'package:my_wealth/provider/broker_provider.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/arguments/broker_detail_args.dart';
import 'package:my_wealth/utils/dialog/create_snack_bar.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/utils/loader/show_loader_dialog.dart';
import 'package:my_wealth/storage/prefs/shared_broker.dart';
import 'package:provider/provider.dart';

class BrokerPage extends StatefulWidget {
  const BrokerPage({Key? key}) : super(key: key);

  @override
  State<BrokerPage> createState() => _BrokerPageState();
}

class _BrokerPageState extends State<BrokerPage> {
  final DateFormat _df = DateFormat('dd/MM/yyyy');
  final ScrollController _scrollController = ScrollController();
  final BrokerAPI _brokerAPI = BrokerAPI();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _filterList = {};
  final TextStyle _filterTypeSelected = const TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.bold);
  final TextStyle _filterTypeUnselected = const TextStyle(fontSize: 10, color: primaryLight, fontWeight: FontWeight.normal);

  late List<BrokerModel> _brokerList;
  late List<BrokerModel> _filterBrokerList;
  late String _filterMode;
  late String _filterSort;

  @override
  void initState() {
    _brokerList = BrokerSharedPreferences.getBrokerList();
    _filterBrokerList = BrokerSharedPreferences.getBrokerList();

    // list all the filter that we want to put here
    _filterList["CD"] = "Code";
    _filterList["VL"] = "Volume";
    _filterList["VA"] = "Value";
    _filterList["FR"] = "Frequency";

    // default filter mode to Code and ASC
    _filterMode = "CD";
    _filterSort = "ASC";

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
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
            Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              color: primaryDark,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "SORT",
                    style: TextStyle(
                      color: primaryLight,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 5,),
                  Expanded(
                    child: GestureDetector(
                      onTap: (() {
                        showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isDismissible: true,
                          builder:(context) {
                            return Container(
                              height: 210,
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 25),
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  const Center(
                                    child: Text("Select Filter"),
                                  ),
                                  ..._filterList.entries.map((e) => GestureDetector(
                                    onTap: (() {
                                      setState(() {
                                        _filterMode = e.key;
                                        _sortedBrokerList();
                                      });
                                      // remove the modal sheet
                                      Navigator.pop(context);
                                    }),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: primaryLight,
                                            width: 1.0,
                                            style: BorderStyle.solid,
                                          )
                                        )
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: (_filterMode == e.key ? accentDark : Colors.transparent),
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(
                                                color: accentDark,
                                                width: 1.0,
                                                style: BorderStyle.solid,
                                              )
                                            ),
                                            child: Center(
                                              child: Text(
                                                e.key,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: (_filterMode == e.key ? textPrimary : accentColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10,),
                                          Text(
                                            e.value,
                                            style: TextStyle(
                                              color: (_filterMode == e.key ? accentColor : textPrimary),
                                              fontWeight: (_filterMode == e.key ? FontWeight.bold : FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )).toList(),
                                ],
                              )
                            );
                          },
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: primaryLight,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(_filterList[_filterMode] ?? 'Code'),
                            ),
                            const SizedBox(width: 5,),
                            const Icon(
                              Ionicons.caret_down,
                              color: accentColor,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5,),
                  GestureDetector(
                    onTap: (() {
                      if (_filterSort != "ASC") {
                        // set state
                        setState(() {
                          _filterSort = "ASC";
                          _sortedBrokerList();
                        });
                      }
                    }),
                    child: SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          "ASC",
                          style: (_filterSort == "ASC" ? _filterTypeSelected : _filterTypeUnselected),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2,),
                  GestureDetector(
                    onTap: (() {
                      if (_filterSort != "DESC") {
                        // set state
                        setState(() {
                          _filterSort = "DESC";
                          _sortedBrokerList();
                        });
                      }
                    }),
                    child: SizedBox(
                      width: 35,
                      child: Center(
                        child: Text(
                          "DESC",
                          style: (_filterSort == "DESC" ? _filterTypeSelected : _filterTypeUnselected),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: RefreshIndicator(
                onRefresh: (() async {
                  showLoaderDialog(context);
                  await _refreshBroker().then((value) {
                    debugPrint("🔃 Refresh Index");
                  }).onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(createSnackBar(message: error.toString()));
                  }).whenComplete(() {
                    // remove the loader
                    Navigator.pop(context);
                  });

                  // once finished just rebuild the widget
                  setState(() {
                    // just rebuild
                  });
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
                                  style: const TextStyle(
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Flexible(
                                  child: Text(
                                    _filterBrokerList[index].brokerFirmName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _informationText(flex: 2, text: "Date", value: _df.format(_filterBrokerList[index].brokerDate.toLocal())),
                                _informationText(text: "Volume", value: formatIntWithNull(_filterBrokerList[index].brokerVolume, true, true)),
                                _informationText(text: "Value", value: formatIntWithNull(_filterBrokerList[index].brokerValue, true, true)),
                                _informationText(text: "Frequency", value: formatIntWithNull(_filterBrokerList[index].brokerFrequency, false, false)),
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
    await _brokerAPI.getBroker().then((resp) async {
      // set the shared preferences and provider for index
      await BrokerSharedPreferences.setBrokerList(resp);
      if (!mounted) return;
      Provider.of<BrokerProvider>(context, listen: false).setBrokerList(resp);

      setState(() {
        // just set state to rebuild
      });
    }).onError((error, stackTrace) {
      throw Exception(error.toString());
    });
  }

  Widget _informationText({int? flex, required String text, required String value}) {
    int flexNum = (flex ?? 1);

    return Expanded(
      flex: flexNum,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
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
    if (_filterSort == "ASC") {
      _filterBrokerList = List<BrokerModel>.from(tempFilter);
    }
    else {
      _filterBrokerList = List<BrokerModel>.from(tempFilter.reversed);
    }
  }
}