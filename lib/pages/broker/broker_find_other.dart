import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class BrokerFindOtherPage extends StatefulWidget {
  const BrokerFindOtherPage({super.key});

  @override
  State<BrokerFindOtherPage> createState() => _BrokerFindOtherPageState();
}

class _BrokerFindOtherPageState extends State<BrokerFindOtherPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _brokerListScrollController = ScrollController();
  late List<BrokerModel> _brokerList;
  late List<BrokerModel> _filterList;

  @override
  void initState() {
    super.initState();

    // get the broker list from shared preferences
    _brokerList = BrokerSharedPreferences.getBrokerList();
    _filterList = _brokerList.toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    _brokerListScrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Find Broker",
            style: TextStyle(
              color: secondaryColor,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (() async {
            // back icon press means that no code being selected
            Navigator.pop(context, null);
          }),
        ),
      ),
      body: MySafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CupertinoSearchTextField(
                controller: _textController,
                onChanged: ((value) {
                  if (value.length >= 2) {
                    _searchList(value);
                  }
                  else {
                    setState(() {
                      _filterList = _brokerList.toList();
                    });
                  }
                }),
                suffixMode: OverlayVisibilityMode.editing,
                style: const TextStyle(
                  color: textPrimary,
                  fontFamily: '--apple-system'
                ),
                decoration: BoxDecoration(
                  color: primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                  controller: _brokerListScrollController,
                  itemCount: _filterList.length,
                  itemBuilder: ((context, index) {
                    return InkWell(
                      onTap: (() {
                        Navigator.pop(context, _filterList[index]);
                      }),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: primaryLight,
                              width: 1.0,
                              style: BorderStyle.solid
                            )
                          )
                        ),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 40,
                              child: Text(
                                _filterList[index].brokerFirmId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _filterList[index].brokerFirmName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5,),
                                  Text(
                                    Globals.dfddMMyyyy.format(_filterList[index].brokerDate),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _searchList(String find) {
    setState(() {
      // clear the filter list first
      _filterList.clear();
      // then loop thru _faveList and check if the company name or code contain the text we want to find
      for (var i = 0; i < _brokerList.length; i++) {
        if (find.length == 2) {
          if (_brokerList[i].brokerFirmId.toLowerCase().contains(find.toLowerCase())) {
            // add this filter list
            _filterList.add(_brokerList[i]);
          }
        }
        else {
          if (_brokerList[i].brokerFirmName.toLowerCase().contains(find.toLowerCase()) || _brokerList[i].brokerFirmId.toLowerCase().contains(find.toLowerCase())) {
            // add this filter list
            _filterList.add(_brokerList[i]);
          }
        }
      }
    });
  }
}