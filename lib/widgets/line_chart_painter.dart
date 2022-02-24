import 'package:flutter/material.dart';
import 'package:my_wealth/themes/colors.dart';
import 'package:my_wealth/utils/function/date_utils.dart';
import 'package:my_wealth/utils/function/format_currency.dart';
import 'package:my_wealth/widgets/heat_graph.dart';

class LineChartPainter extends CustomPainter {
  final List<GraphData> data;
  const LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    // check what is the size now
    debugPrint(size.height.toString() + " / " + size.width.toString());

    // calculate the center
    Offset _center = Offset(size.width / 2, size.height / 2);

    // first let's draw the border
    _drawBorder(canvas, size, _center);

    // then let's draw the line
    _drawLine(canvas, size, _center);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _maxData() {
    // loop on the data
    double _max = double.minPositive;

    for (GraphData value in data) {
      if(_max < value.price) {
        _max = value.price;
      }
    }

    return _max;
  }

  double _minData() {
    // loop on the data
    double _min = double.maxFinite;

    for (GraphData value in data) {
      if(_min > value.price) {
        _min = value.price;
      }
    }

    return _min;
  }

  void _drawBorder(Canvas canvas, Size size, Offset center) {
    // set the rectangle position
    Rect _rect = Rect.fromCenter(center: center, width: (size.width - 20), height: (size.height - 20));
    Paint _border = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // draw the rectangle
    canvas.drawRect(_rect, _border);
  }

  void _drawLine(Canvas canvas, Size size, Offset center) {
    // get the max and min data from the graph
    double _max = _maxData();
    double _min = _minData();

    // create the rect that we will use as a guide for the graph
    Rect _graphRect = Rect.fromLTWH(70, 10, (size.width - 80), (size.height - 60));
    Paint _graphRectBorder = Paint()
      ..color = primaryDark
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    Paint _graphRectBorderWhite = Paint()
      ..color = primaryLight
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // draw the guides
    // draw vertical lines
    double _xLeft = _graphRect.left;
    double _guideW = _graphRect.size.width / data.length;
    for(int i = 0; i < data.length; i++) {
      Offset _p1 = Offset(_xLeft, _graphRect.bottom);
      Offset _p2 = Offset(_xLeft, _graphRect.top);
      _xLeft += _guideW;

      if(i > 0 && (i%10 == 0)) {
        debugPrint(data[i].price.toString());
        canvas.drawLine(_p1, _p2, _graphRectBorderWhite);
        _drawText(canvas, Offset(_xLeft, _graphRect.bottom), 60, formatDate(date: data[i].date, format: "dd-MMM"), 0, 10);
      }
      else {
        canvas.drawLine(_p1, _p2, _graphRectBorder);
      }
    }

    // draw horizontal line
    double _yD = _graphRect.size.height / 4;
    for(int i = 0; i < 4; i++) {
      Offset _p1 = Offset(_graphRect.left, _graphRect.bottom - (_yD * i));
      Offset _p2 = Offset(_graphRect.right, _graphRect.bottom - (_yD * i));
      canvas.drawLine(_p1, _p2, _graphRectBorder);

      double _currVal = _min + (((_max - _min) / 4.0) * i.toDouble());
      _drawText(canvas, Offset(_graphRect.left, _graphRect.bottom - (_yD * i) - 5), 60, formatDecimal(_currVal, 2), 10, 0);
    }

    // once guidelines finished, we can draw the actual graph
    double _gap = _graphRect.width / (data.length.toDouble() - 1);
    double _ratio = _graphRect.height / (_max - _min);
    Path _pUp = Path();
    Path _pDown = Path();
    double _x = _graphRect.left;
    double _y = 0;
    bool _isFirst = true;
    double _prevPrice = double.minPositive;

    // loop thru data
    for (GraphData value in data) {
      _y = 10 + _graphRect.height - ((value.price - _min) * _ratio);

      // check whether this is the first data?
      if(_isFirst) {
        _pUp.moveTo(_x, _y);
        _pDown.moveTo(_x, _y);

        _isFirst = false;
      }
      else {
        // check whether price go up or go down?
        if(value.price > _prevPrice) {
          _pUp.lineTo(_x, _y);
          _pDown.moveTo(_x, _y);
        }
        else {
          _pUp.moveTo(_x, _y);
          _pDown.lineTo(_x, _y);
        }
      }

      // next column
      _prevPrice = value.price;
      _x += _gap;
    }

    // end of chart

    // draw the path
    Paint dpUp = Paint()
      ..color = Colors.green
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    Paint dpDown = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(_pUp, dpUp);
    canvas.drawPath(_pDown, dpDown);
  }

  void _drawText(Canvas canvas, Offset position, double width, String text, double left, double top) {
    final TextSpan _textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
      ),
    );

    final TextPainter _textPainter = TextPainter(
      text: _textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    _textPainter.layout(minWidth: 0, maxWidth: width);
    _textPainter.paint(canvas, Offset(position.dx - (_textPainter.width + left), (position.dy + top)));
  }
}