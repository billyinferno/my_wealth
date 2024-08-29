import 'package:flutter/material.dart';
import 'package:my_wealth/_index.g.dart';

class Candle {
  final double centerX;
  final double wickHighY;
  final double wickLowY;
  final double candleHighY;
  final double candleLowY;
  final String? dateText;
  final Paint paint;
  
  Candle({
    required this.centerX,
    required this.wickHighY,
    required this.wickLowY,
    required this.candleHighY,
    required this.candleLowY,
    required this.paint,
    this.dateText,
  });
}

class StockCandleStickPainter extends CustomPainter {
  final List<InfoSahamPriceModel> stockData;
  final int maxHigh;
  final int minLow;
  int? padding;
  final int? dateOffset;

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
    this.dateOffset,
    this.padding,
  }) : _wickPaint = Paint()..color = Colors.grey,
       _gainPaint = Paint()..color = Colors.green,
       _lossPaint = Paint()..color = Colors.red,
       _neutralPaint = Paint()..color = Colors.white,
       _graphRectBorder = Paint()..color = primaryDark.withOpacity(0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    padding = (padding ?? 20);
    totalData = stockData.length;

    // return if no stock data
    if (stockData.isEmpty) {
      // draw border only if the stock is empty
      _drawBorder(canvas: canvas, size: size);
      return;
    }

    // draw the max - min and the middle
    _drawCurrency(canvas: canvas, size: size);

    // draw the candles
    _drawCandles(canvas: canvas, size: size);

    // draw border
    _drawBorder(canvas: canvas, size: size);
  }

  void _drawBorder({
    required Canvas canvas,
    required Size size
  }) {
    // set the rectangle position
    Rect rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: (size.width - padding!), height: (size.height));
    Paint border = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // draw the rectangle
    canvas.drawRect(rect, border);
  }

  void _drawCandles({
    required Canvas canvas,
    required Size size
  }) {
    List<Candle> candles = _generateCandleSticks(size: size);
    double candleWidth = (size.width - padding!) / (totalData! + 1) - 1.5;

    // paint the candlestick
    for (Candle candle in candles) {
      // check if dateText is not null?
      if (candle.dateText!.isNotEmpty) {
        // draw the text here
        _drawText(
          canvas: canvas,
          position: Offset(candle.centerX, size.height),
          width: 60,
          text: candle.dateText!,
          left: 0,
          top: 0
        );

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

  List<Candle> _generateCandleSticks({required Size size}) {
    final double pixelPerCandle = (size.width - padding!) / (totalData! + 1);
    final double pixelPerPrice = size.height / (maxHigh - minLow);

    List<Candle> candles = [];
    Paint candleColor;
    int candleHigh, candleLow;
    bool samePrice;
    String dateText = "";
    int adjustedOpenPrice;
    int currentDateOffset = (dateOffset ?? 10);
    
    for(int i = 0; i < totalData!; i++) {
      dateText = "";
      samePrice = false;
      candleColor = _neutralPaint;

      // get the adjusted open price
      adjustedOpenPrice = stockData[i].adjustedOpenPrice;
      // check if this is 0, if this is 0, then we can use the previous
      // closing price as the adjusted open price for today
      if (adjustedOpenPrice <= 0) {
        // ensure that previous closing price is more than 0
        if ((stockData[i].prevClosingPrice ?? 0) > 0) {
          adjustedOpenPrice = stockData[i].prevClosingPrice!;
        }
        else {
          // if even previous closing price is 0, then we can use the
          // adjusted closing price, assuming opening and closing will have
          // the same price.
          adjustedOpenPrice = stockData[i].adjustedClosingPrice;
        }
      }

      // instead checking with previous data (as the order is descending)
      // we can just check what is the open price and the close price?
      // if close price > open price, then it means that we got some gain
      if (adjustedOpenPrice < stockData[i].lastPrice) {
        candleColor = _gainPaint;
      }
      else if (adjustedOpenPrice > stockData[i].lastPrice) {
        candleColor = _lossPaint;
      }

      if (adjustedOpenPrice > stockData[i].adjustedClosingPrice) {
        candleHigh = adjustedOpenPrice - minLow;
        candleLow = stockData[i].adjustedClosingPrice - minLow;
      }
      else {
        candleHigh = stockData[i].adjustedClosingPrice - minLow;
        candleLow = adjustedOpenPrice - minLow;
      }
      // check if high and low is the same, if the same we need to at least paint a "-"
      if (candleHigh == candleLow) {
        samePrice = true;
      }

      // check if current i % 10?
      if (i % currentDateOffset == 0) {
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
  bool shouldRepaint(StockCandleStickPainter oldDelegate) {
    return listEquals<InfoSahamPriceModel>(oldDelegate.stockData, stockData);
    
  }

  void _drawText({
    required Canvas canvas,
    required Offset position,
    required double width,
    required String text,
    required double left,
    required double top
  }) {
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
  
  void _drawCurrency({
    required Canvas canvas,
    required Size size
  }) {
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
      _drawText(
        canvas: canvas,
        position: Offset(size.width - 12, (maxHigh - currentPrice) * pixelPerPrice),
        width: 60,
        text: formatCurrency(
          currentPrice,
          checkThousand: false,
          showDecimal: false,
          shorten: true,
        ),
        left: 0,
        top: 0
      );

      // next price
      currentPrice -= average;
    }
  }
}