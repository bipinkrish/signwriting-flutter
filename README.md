# SignWriting Flutter

[![pub package](https://img.shields.io/pub/v/signwriting_flutter.svg)](https://pub.dev/packages/signwriting_flutter)

This is flutter implementation of its [python counterpart](https://github.com/sign-language-processing/signwriting). flutter utilities for SignWriting formats, tokenizer, visualizer and utils.

Most of the implementation is done at [signwriting](https://pub.dev/packages/signwriting)

## How to use

Download both the font files from [assets/fonts](https://github.com/bipinkrish/signwriting-flutter/tree/main/assets/fonts) and place them in the `assets/fonts` directory from your project's root folder.

```yaml
dependencies:
  signwriting_flutter: ^latest_version
```

```yaml
flutter:
  fonts:
    - family: SuttonSignWritingFill
      fonts:
        - asset: assets/fonts/SuttonSignWritingFill.ttf

    - family: SuttonSignWritingLine
      fonts:
        - asset: assets/fonts/SuttonSignWritingLine.ttf
```

## Example

```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signwriting_flutter/signwriting_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignWriting Image Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SignWriting Image Test'),
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: FutureBuilder<Uint8List>(
            future: signwritingToImage(
              'AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S20544510x500S10019476x475',
              trustBox: false,
              lineColor: Colors.deepOrange,
              fillColor: Colors.white,
            ),
            builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Image.memory(snapshot.data!);
                } else {
                  return const Text('Failed to render SignWriting image');
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
```