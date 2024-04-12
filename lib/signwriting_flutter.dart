library signwriting_flutter;

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signwriting/signwriting.dart';

// Function to calculate the size of a symbol based on its representation
Size _getSymbolSize(String symbol) {
  // Getting the line representation of the symbol
  final lineId = symbolLine(key2id(symbol));
  // Defining the font size
  const fontSize = 30.0;
  // Creating a TextPainter to measure the size of the symbol
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
  // Layout the TextPainter to calculate the size
  paint.layout();
  return paint.size;
}

// Function to convert a SignWriting FSW string to an image represented as Uint8List
Future<Uint8List> signwritingToImage(
  String fsw, {
  bool trustBox = true,
  Color lineColor = Colors.black,
  Color fillColor = Colors.transparent,
}) async {
  // Convert the FSW string to a Sign object
  final sign = fswToSign(fsw);
  // If the sign has no symbols, return an empty Uint8List
  if (sign.symbols.isEmpty) {
    return Uint8List(0);
  }

  // Calculate the minimum x and y coordinates of the sign symbols
  final positions = sign.symbols.map((s) => s.position).toList();
  final minX = positions.map((p) => p.item1.toDouble()).reduce(min);
  final minY = positions.map((p) => p.item2.toDouble()).reduce(min);

  // Calculate the maximum x and y coordinates of the sign symbols
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

  // Create a PictureRecorder to record drawing commands
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);

  // Create TextPainters for drawing the fill and line of each symbol
  final fillPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );
  final linePainter = TextPainter(
    textDirection: TextDirection.ltr,
    textWidthBasis: TextWidthBasis.longestLine,
  );

  // Draw each symbol onto the canvas
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

    // Paint the fill and line of the symbol onto the canvas
    fillPainter.paint(canvas, ui.Offset(x, y));
    linePainter.paint(canvas, ui.Offset(x, y));
  }

  // End recording the drawing commands and obtain a Picture
  final picture = pictureRecorder.endRecording();
  // Convert the Picture to an Image and then to ByteData
  final img = await picture.toImage((maxX - minX).ceil(), (maxY - minY).ceil());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  // Convert the ByteData to Uint8List representing the image
  final bytes = data!.buffer.asUint8List();

  return bytes;
}
