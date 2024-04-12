library signwriting_flutter;

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signwriting/signwriting.dart';

Size _getSymbolSize(String symbol) {
  final lineId = symbolLine(key2id(symbol));
  const fontSize = 30.0;
  final paint = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: lineId,
      style: const TextStyle(
        fontFamily: 'SuttonSignWritingLine',
        fontSize: fontSize,
      ),
    ),
  );
  paint.layout();
  return paint.size;
}

Future<Uint8List> signwritingToImage(
  String fsw, {
  bool trustBox = true,
  Color lineColor = Colors.black,
  Color fillColor = Colors.transparent,
}) async {
  final sign = fswToSign(fsw);
  if (sign.symbols.isEmpty) {
    return Uint8List(0);
  }

  final positions = sign.symbols.map((s) => s.position).toList();
  final minX = positions.map((p) => p.item1.toDouble()).reduce(min);
  final minY = positions.map((p) => p.item2.toDouble()).reduce(min);

  double maxX, maxY;
  if (trustBox) {
    maxX = sign.box.position.item1.toDouble();
    maxY = sign.box.position.item2.toDouble();
  } else {
    maxX = maxY = 0;
    for (final symbol in sign.symbols) {
      final symbolX = symbol.position.item1.toDouble();
      final symbolY = symbol.position.item2.toDouble();
      final symbolWidth = _getSymbolSize(symbol.symbol).width;
      final symbolHeight = _getSymbolSize(symbol.symbol).height;
      maxX = max(maxX, symbolX + symbolWidth);
      maxY = max(maxY, symbolY + symbolHeight);
    }
  }

  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);

  final fillPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );
  final linePainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );

  for (final symbol in sign.symbols) {
    final x = symbol.position.item1 - minX;
    final y = symbol.position.item2 - minY;
    final symbolId = key2id(symbol.symbol);
    fillPainter.text = TextSpan(
      text: symbolFill(symbolId),
      style: TextStyle(
        fontFamily: 'SuttonSignWritingFill',
        fontSize: 30.0,
        color: fillColor,
      ),
    );
    linePainter.text = TextSpan(
      text: symbolLine(symbolId),
      style: TextStyle(
        fontFamily: 'SuttonSignWritingLine',
        fontSize: 30.0,
        color: lineColor,
      ),
    );
    fillPainter.layout();
    linePainter.layout();

    fillPainter.paint(canvas, ui.Offset(x, y));
    linePainter.paint(canvas, ui.Offset(x, y));
  }

  final picture = pictureRecorder.endRecording();
  final img = await picture.toImage((maxX - minX).ceil(), (maxY - minY).ceil());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  final bytes = data!.buffer.asUint8List();

  return bytes;
}
