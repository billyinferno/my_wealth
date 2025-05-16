import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:my_wealth/_index.g.dart';

class SimpleCompanyInfo extends StatelessWidget {
  final ScrollController? controller;
  final CompanyDetailModel? company;
  final int risk;
  final Function()? onTap;
  const SimpleCompanyInfo({
    super.key,
    this.controller,
    required this.company,
    this.risk = 30,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double currentPrice = 0;
    double prevPrice = 0;
    IconData currentIcon = Ionicons.remove;
    Color currentRiskColor = Colors.white;
    double diffPrice = 0;

    if (company == null) {
      return SizedBox.shrink();
    }

    // calculate all the variable needed
    // first get the current price
    currentPrice = (company!.companyNetAssetValue ?? 0);

    // ensure current price is not 0
    if (currentPrice <= 0) {
      return const SizedBox.shrink();
    }
    
    // get previous price
    prevPrice = (company!.companyPrevPrice ?? 0);
    
    // in case previous price is 0, then use prev closing price
    if (prevPrice <= 0) {
      prevPrice = (company!.companyPrevClosingPrice ?? 0);
    }

    // in case previous price still 0, then default it same as current price
    if (prevPrice <= 0) {
      prevPrice = currentPrice;
    }

    currentRiskColor = riskColor(
      value: currentPrice,
      cost: prevPrice,
      riskFactor: risk
    );

    // get the diff price
    diffPrice = currentPrice - prevPrice;
    if (diffPrice > 0) {
      currentIcon = Ionicons.caret_up;
    } else if (diffPrice < 0) {
      currentIcon = Ionicons.caret_down;
    }

    return InkWell(
      onTap: () async {
        // check if onTap is not null
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: primaryLight,
              width: 1.0,
              style: BorderStyle.solid,
            )
          )
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 10,
                color: currentRiskColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: (company!.companyFCA ?? false),
                      child: Container(
                        width: double.infinity,
                        color: secondaryDark,
                        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Ionicons.warning,
                              size: 10,
                              color: secondaryLight,
                            ),
                            const SizedBox(width: 5,),
                            Text(
                              "This company is flagged with Full Call Auction",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              company!.companyName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2,),
                            Expanded(
                              child: SingleChildScrollView(
                                controller: controller,
                                physics: const AlwaysScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: (company!.companyType.isNotEmpty),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: secondaryLight,
                                            style: BorderStyle.solid,
                                            width: 1.0
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Text(
                                          company!.companyType,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: secondaryLight,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Visibility(
                                      visible: (
                                        company!.companyType.toLowerCase() !=
                                        company!.companyIndustry.toLowerCase()
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: secondaryLight,
                                            style: BorderStyle.solid,
                                            width: 1.0
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: Text(
                                          company!.companyIndustry,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: secondaryLight,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  formatCurrency(currentPrice),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                Icon(
                                  currentIcon,
                                  color: currentRiskColor,
                                  size: 11,
                                ),
                                const SizedBox(width: 5,),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: currentRiskColor,
                                        width: 2.0,
                                        style: BorderStyle.solid,
                                      ),
                                    )
                                  ),
                                  child: Text(
                                    formatCurrency(currentPrice - prevPrice),
                                    style: TextStyle(
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Expanded(child: SizedBox(),),
                                const Icon(
                                  Ionicons.time_outline,
                                  color: primaryLight,
                                  size: 11,
                                ),
                                const SizedBox(width: 5,),
                                Text(
                                  Globals.dfddMMyyyy.formatDateWithNull(
                                    company!.companyLastUpdate,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}