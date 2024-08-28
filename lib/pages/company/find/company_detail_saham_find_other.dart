import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class CompanyDetailSahamFindOtherPage extends StatefulWidget {
  final Object? args;
  const CompanyDetailSahamFindOtherPage({super.key, required this.args});

  @override
  State<CompanyDetailSahamFindOtherPage> createState() => _CompanyDetailSahamFindOtherPageState();
}

class _CompanyDetailSahamFindOtherPageState extends State<CompanyDetailSahamFindOtherPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final CompanyAPI _companyAPI = CompanyAPI();

  late List<OtherCompanyInfo> _companyList;
  late List<OtherCompanyInfo> _similarList;
  late List<OtherCompanyInfo> _filterList;
  late String _currentCode;

  late Future<bool> _getData;

  @override
  void initState() {
    // initialize all the variable needed
    _currentCode = widget.args as String;

    _companyList = [];
    _similarList = [];

    // get the data
    _getData = _getInitData();

    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading find other stock');
        }
        else if (snapshot.hasData) {
          return _body();
        }
        else {
          return const CommonLoadingPage();
        }
      },
    );
  }

  Widget _body() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Find Other Stock",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: CupertinoSearchTextField(
                controller: _textController,
                onChanged: ((value) {
                  if (value.length >= 3) {
                    searchList(value);
                  }
                  else {
                    setState(() {
                      _filterList = List<OtherCompanyInfo>.from(_similarList);
                    });
                  }
                }),
                suffixIcon: const Icon(
                  Ionicons.trash_bin_outline,
                  color: secondaryColor,
                ),
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
            ),
            const SizedBox(height: 10,),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(
                "Showed ${_filterList.length} ${(_textController.text.length < 3) ? 'similar ' : ''}company(s)",
                style: const TextStyle(
                  color: primaryLight,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filterList.length,
                itemBuilder: ((context, index) {
                  return InkWell(
                    onTap: (() {
                      Navigator.pop(context, _filterList[index].code);
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
                          ),
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "(${_filterList[index].code}) ${_filterList[index].name}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5,),
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                _companyType(text: (_filterList[index].sectorName == null ? '' : _filterList[index].subSectorName!.replaceAll(RegExp(r'&amp;'), '&'))),
                                _companyType(text: (_filterList[index].industryName == null ? '' : _filterList[index].industryName!.replaceAll(RegExp(r'&amp;'), '&'))),
                                _companyType(text: (_filterList[index].sectorName == null ? '' : _filterList[index].sectorName!.replaceAll(RegExp(r'&amp;'), '&'))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              _gainBox(header: "One Year", value: "${
                                formatDecimalWithNull(
                                  value: _filterList[index].oneYear,
                                  times: 100,
                                  decimal: 2,
                                )}%"
                              ),
                              const SizedBox(width: 5,),
                              _gainBox(header: "Three Year", value: "${
                                formatDecimalWithNull(
                                  value: _filterList[index].threeYear,
                                  times: 100,
                                  decimal: 2,
                                )}%"
                              ),
                              const SizedBox(width: 5,),
                              _gainBox(header: "Five Year", value: "${
                                formatDecimalWithNull(
                                  value: _filterList[index].fiveYear,
                                  times: 100,
                                  decimal: 2
                                )}%"
                              ),
                              const SizedBox(width: 5,),
                              _gainBox(header: "Ten Year", value: "${
                                formatDecimalWithNull(
                                  value: _filterList[index].tenYear,
                                  times: 100,
                                  decimal: 2,
                                )}%"
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ); 
  }

  Widget _companyType({required String text}) {
    return Container(
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: secondaryLight,
          width: 1.0,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: secondaryLight,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _gainBox({required String header, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: accentColor,
                  width: 1.0,
                  style: BorderStyle.solid,
                )
              )
            ),
            child: Text(
              header,
              style: const TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 5,),
          Text(
            value,
            style: const TextStyle(
                fontSize: 10,
              ),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  Future<bool> _getInitData() async {
    // get the data from api
    await _companyAPI.getOtherCompany(companyCode: _currentCode).then((resp) {
      _companyList = resp.all;
      _similarList = resp.similar;
    }).onError((error, stackTrace) {
      Log.error(
        message: 'Error getting data from server',
        error: error,
        stackTrace: stackTrace,
      );

      throw Exception('Error when get the data from server');
    },);

    // once finished then we can set the filter list same as similar list
    // as  we will showed this when the search text is empty
    _filterList = _similarList;

    return true;
  }

  void searchList(String find) {
    // clear the filter list first
    _filterList.clear();
    // then loop thru _faveList and check if the company name or code contain the text we want to find
    for (var i = 0; i < _companyList.length; i++) {
      if (_companyList[i].name.toLowerCase().contains(find.toLowerCase()) || _companyList[i].code.toLowerCase().contains(find.toLowerCase())) {
        // add this filter list
        _filterList.add(_companyList[i]);
      }
    }

    setState(() {
      // just set state to rebuild the widget
    });
  }
}