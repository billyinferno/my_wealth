import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_wealth/api/company_api.dart';
import 'package:my_wealth/model/company/company_list_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/widgets/page/common_error_page.dart';
import 'package:my_wealth/widgets/page/common_loading_page.dart';

class CompanyDetailFindOtherPage extends StatefulWidget {
  final Object? type;
  const CompanyDetailFindOtherPage({Key? key, required this.type}) : super(key: key);

  @override
  State<CompanyDetailFindOtherPage> createState() => _CompanyDetailFindOtherPageState();
}

class _CompanyDetailFindOtherPageState extends State<CompanyDetailFindOtherPage> {
  final CompanyAPI _companyAPI = CompanyAPI();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _companyListController = ScrollController();

  late Future<bool> _getData;
  late String _companyType;
  late List<CompanyListModel> _companyList;
  late List<CompanyListModel> _filterList;

  @override
  void initState() {
    super.initState();
    _companyType = widget.type as String;
    _companyList = [];
    _getData = _getCompanyList();
  }

  @override
  void dispose() {
    _textController.dispose();
    _companyListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return const CommonErrorPage(errorText: 'Error loading mutual fund data');
        }
        else if (snapshot.hasData) {
          return _generatePage();
        }
        else {
          return const CommonLoadingPage();
        }
      })
    );
  }

  Widget _generatePage() {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "Find $_companyType",
              style: const TextStyle(
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
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CupertinoSearchTextField(
                  controller: _textController,
                  onChanged: ((value) {
                    if (value.length >= 3) {
                      _searchList(value);
                    }
                    else {
                      setState(() {
                        _filterList = _companyList.toList();
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
                    controller: _companyListController,
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
                              Visibility(
                                visible: _filterList[index].companySymbol.isNotEmpty,
                                child: SizedBox(
                                  width: 60,
                                  child: Text(
                                    _filterList[index].companySymbol,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                )
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _filterList[index].companyName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5,),
                                    Text(
                                      _filterList[index].companyType,
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
      ),
    );
  }

  Future<bool> _getCompanyList() async {
    // try to get the company data from server
    try {
      await _companyAPI.findCompany(_companyType).then((resp) {
        _companyList = resp;
        _filterList = _companyList.toList();
      });
    }
    catch(error) {
      throw 'Error when try to get the data from server';
    }

    return true;
  }

  void _searchList(String find) {
    setState(() {
      // clear the filter list first
      _filterList.clear();
      // then loop thru _faveList and check if the company name or code contain the text we want to find
      for (var i = 0; i < _companyList.length; i++) {
        if (_companyList[i].companyName.toLowerCase().contains(find.toLowerCase()) || _companyList[i].companySymbol.toLowerCase().contains(find.toLowerCase())) {
          // add this filter list
          _filterList.add(_companyList[i]);
        }
      }
    });
  }
}