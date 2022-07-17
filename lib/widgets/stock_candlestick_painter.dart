import 'package:flutter/material.dart';
import 'package:my_wealth/model/info_saham_price_model.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';

class Candle {
  final double centerX;
  final double wickHighY;
  final double wickLowY;
  final double candleHighY;
  final double candleLowY;
  final String? dateText;
  final Paint paint;
  
  Candle({required this.centerX, required this.wickHighY, required this.wickLowY, required this.candleHighY, required this.candleLowY, required this.paint, this.dateText});
}

class StockCandleStickPainter extends CustomPainter {
  final List<InfoSahamPriceModel> stockData;
  final int maxHigh;
  final int minLow;
  int? padding;
  final Paint _wickPaint;
  final Paint _gainPaint;
  final Paint _lossPaint;
  final Paint _neutralPaint;
  final Paint _graphRectBorder;
  final double _wickWidth = 1.0;
  int? totalData;

  StockCandleStickPainter({
    required this.stockData,
    required this.maxHigh,
    required this.minLow,
    this.padding,
  }) : _wickPaint = Paint()..color = Colors.grey,
       _gainPaint = Paint()..color = Colors.green,
       _lossPaint = Paint()..color = Colors.red,
       _neutralPaint = Paint()..color = Colors.white,
       _graphRectBorder = Paint()..color = primaryDark.withOpacity(0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    padding = (padding ?? 20);
    totalData = stockData.length - 1;

    // return if no stock data
    if (stockData.isEmpty) {
      // draw border only if the stock is empty
      _drawBorder(canvas, size);
      return;
    }

    // draw the max - min and the middle
    _drawCurrency(canvas, size);

    // draw the candles
    _drawCandles(canvas, size);

    // draw border
    _drawBorder(canvas, size);
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

  void _drawCandles(Canvas canvas, Size size) {
    List<Candle> candles = _generateCandleSticks(size);
    double candleWidth = (size.width - padding!) / (totalData! + 1) - 1.5;

    // paint the candlestick
    for (Candle candle in candles) {
      // check if dateText is not null?
      if (candle.dateText!.isNotEmpty) {
        // draw the text here
        _drawText(canvas, Offset(candle.centerX, size.height), 60, candle.dateText!, 0, 0);

        // draw the horizontal line
        Offset p1 = Offset(candle.centerX, (size.height));
        Offset p2 = Offset(candle.centerX, 0);
        canvas.drawLine(p1, p2, _graphRectBorder);
      }

      // paint the wick
      canvas.drawRect(
        Rect.fromLTRB(
          candle.centerX - (_wickWidth / 2),
          size.height - candle.wickHighY,
          candle.centerX + (_wickWidth / 2),
          size.height - candle.wickLowY
        ),
        _wickPaint
      );

      // paint the candle
      canvas.drawRect(
        Rect.fromLTRB(
          candle.centerX - (candleWidth / 2),
          size.height - candle.candleHighY,
          candle.centerX + (candleWidth / 2),
          size.height - candle.candleLowY
        ),
        candle.paint 
      );
    }
  }

  List<Candle> _generateCandleSticks(Size size) {
    final double pixelPerCandle = (size.width - padding!) / (totalData! + 1);
    final double pixelPerPrice = size.height / (maxHigh - minLow);

    List<Candle> candles = [];
    Paint candleColor;
    int candleHigh, candleLow;
    bool samePrice;
    String dateText = "";
    for(int i = 0; i < totalData!; i++) {
      dateText = "";
      samePrice = false;
      candleColor = _neutralPaint;
      // check if current record is the more than the previous one?
      if (i < stockData.length - 1) {
        if (stockData[i].lastPrice > stockData[i + 1].lastPrice) {
          candleColor = _gainPaint;
        }
        else if (stockData[i].lastPrice < stockData[i + 1].lastPrice) {
          candleColor = _lossPaint;
        }
      }

      if (stockData[i].adjustedOpenPrice > stockData[i].adjustedClosingPrice) {
        candleHigh = stockData[i].adjustedOpenPrice - minLow;
        candleLow = stockData[i].adjustedClosingPrice - minLow;
      }
      else {
        candleHigh = stockData[i].adjustedClosingPrice - minLow;
        candleLow = stockData[i].adjustedOpenPrice - minLow;
      }
      // check if high and low is the same, if the same we need to at least paint a "-"
      if (candleHigh == candleLow) {
        samePrice = true;
      }

      // check if current i % 10?
      if (i % 10 == 0) {
        dateText = formatDate(date: stockData[i].date, format: 'dd/MM');
      }

      candles.add(Candle(
        centerX: (totalData! - i) * pixelPerCandle + (padding! / 2),
        wickHighY: (stockData[i].adjustedHighPrice - minLow) * pixelPerPrice,
        wickLowY: (stockData[i].adjustedLowPrice - minLow) * pixelPerPrice,
        candleHighY: candleHigh * pixelPerPrice + (samePrice ? 1 : 0),
        candleLowY: candleLow * pixelPerPrice,
        paint: candleColor,
        dateText: dateText,
      ));
    }
    
    return candles;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawText(Canvas canvas, Offset position, double width, String text, double left, double top) {
    final TextSpan textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.5),
        fontSize: 10,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    
    textPainter.layout(minWidth: 0, maxWidth: width);
    textPainter.paint(canvas, Offset(position.dx - (textPainter.width + left), (position.dy + top)));
  }
  
  void _drawCurrency(Canvas canvas, Size size) {
    double average = (maxHigh - minLow) / 4;
    double pixelPerPrice = (size.height / (maxHigh - minLow));

    // draw 3 indicator
    double currentPrice = maxHigh.toDouble();
    for (int i = 0; i < 4; i++) {
      // draw horizontal line
      Offset p1 = Offset(0 + (padding! / 2), (maxHigh - currentPrice) * pixelPerPrice);
      Offset p2 = Offset(size.width - (padding! / 2), (maxHigh - currentPrice) * pixelPerPrice);
      canvas.drawLine(p1, p2, _graphRectBorder);

      // calculate the position
      _drawText(canvas, Offset(size.width - 12, (maxHigh - currentPrice) * pixelPerPrice), 60, formatCurrency(currentPrice, false, false, true), 0, 0);

      // next price
      currentPrice -= average;
    }
  }
}