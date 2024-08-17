import 'package:flutter/cupertino.dart';
import 'package:my_wealth/_index.g.dart';

class StockChart extends StatelessWidget {
  final List<InfoSahamPriceModel> data;
  final int high;
  final int low;
  final int maxVol;
  final double? candleHeight;
  final double? volumeHeight;
  final int? dateOffset;
  const StockChart({
    super.key,
    required this.data,
    required this.high,
    required this.low,
    required this.maxVol,
    this.candleHeight,
    this.volumeHeight,
    this.dateOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: (candleHeight ?? 220),
          child: CustomPaint(
            size: Size.infinite,
            painter: StockCandleStickPainter(
              stockData: data,
              maxHigh: high,
              minLow: low,
              dateOffset: dateOffset,
            ),
          ),
        ),
        const SizedBox(height: 15,),
        SizedBox(
          height: (volumeHeight ?? 30),
          child: CustomPaint(
            size: Size.infinite,
            painter: StockVolumePainter(
              stockData: data,
              maxVolume: maxVol,
            ),
          ),
        ),
      ],
    );
  }
}