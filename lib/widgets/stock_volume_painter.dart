import 'package:flutter/material.dart';
import 'package:my_wealth/model/info_saham_price_model.dart';
import 'package:my_wealth/themes/colors.dart';

class Bar {
  final double width;
  final double height;
  final double centerX;
  final Paint paint;

  Bar({required this.width, required this.height, required this.centerX, required this.paint});
}

class StockVolumePainter extends CustomPainter {
  final List<InfoSahamPriceModel> stockData;
  final int maxVolume;
  final Paint _gainPaint;
  final Paint _lossPaint;
  final Paint _neutralPaint;
  double? padding;
  int? totalData;

  StockVolumePainter(
    {required this.stockData, required this.maxVolume, this.padding}
  ) : _gainPaint = Paint()..color = Colors.green.withOpacity(0.5),
      _lossPaint = Paint()..color = Colors.red.withOpacity(0.5),
      _neutralPaint = Paint()..color = Colors.white.withOpacity(0.5);

  @override
  void paint(Canvas canvas, Size size) {
    // if the stock data is empty, then just return border only
    if (stockData.isEmpty) {
      // just draw a border if the stock is empty
      _drawBorder(canvas, size);
      return;
    }

    totalData = stockData.length - 1;
    padding = (padding ?? 20);

    _drawVolume(canvas, size);
    _drawBorder(canvas, size);
  }

  List<Bar> _generateBars(Size size) {
    // since we will use maxVolume to perform calculation, in case that the max volume
    // is 0, just return with empty list, since it means that there are no movement
    // for this stock.
    if (maxVolume == 0) return [];

    // calculate maximum width and heigh that we can use per bar
    final double pixelPerBar = (size.width - padding!) / stockData.length;
    final double pixelPerOrder = size.height / maxVolume;
    final double barWidth = (size.width - padding!) / (totalData! + 1) - 1.5;

    List<Bar> bars = [];
    Paint volumePaint = _neutralPaint;
    for (int i = 0; i < totalData!; i++) {
      // check if current record is the more than the previous one?
      volumePaint = _neutralPaint;
      if (i < stockData.length - 1) {
        if (stockData[i].lastPrice > stockData[i + 1].lastPrice) {
          volumePaint = _gainPaint;
        }
        else if (stockData[i].lastPrice < stockData[i + 1].lastPrice) {
          volumePaint = _lossPaint;
        }
      }

      bars.add(
        Bar(
          width: barWidth,
          height: (stockData[i].volume * pixelPerOrder),
          centerX: ((totalData! - i) * pixelPerBar) + (padding! / 2),
          paint: volumePaint,
        )
      );
    }

    return bars;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawVolume(Canvas canvas, Size size) {
    // generate the bar that we will need to paint
    List<Bar> bars = _generateBars(size);

    // now let's painting the bar
    for (Bar bar in bars) {
      canvas.drawRect(
        Rect.fromLTWH(
          bar.centerX - (bar.width / 2),
          size.height - bar.height,
          bar.width,
          bar.height
        ),
        bar.paint
      );
    }
  }

  void _drawBorder(Canvas canvas, Size size) {
    // set the rectangle position
    Rect rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: (size.width - padding!), height: (size.height));
    Paint border = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // draw the rectangle
    canvas.drawRect(rect, border);
  }

}