# SignWriting Flutter

[![pub package](https://img.shields.io/pub/v/signwriting_flutter.svg)](https://pub.dev/packages/signwriting_flutter)

This is flutter implementation of its [python counterpart](https://github.com/sign-language-processing/signwriting). flutter utilities for SignWriting formats, tokenizer, visualizer and utils.

Most of the implementation is done at [signwriting](https://pub.dev/packages/signwriting)

## How to use

Download both the font files from [assets/fonts](https://github.com/bipinkrish/signwriting-flutter/tree/main/assets/fonts) and place them in the `assets/fonts` directory from your project's root folder or run the below commands in your root folder to set it up

```bash
mkdir -p assets/fonts/
cd assets/fonts/

wget https://github.com/bipinkrish/signwriting-flutter/raw/refs/heads/main/assets/fonts/SuttonSignWritingFill.ttf
wget https://github.com/bipinkrish/signwriting-flutter/raw/refs/heads/main/assets/fonts/SuttonSignWritingLine.ttf

cd ../../
```

in your `pubspec.yaml` file add the below blocks

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

class SignWritingWidget extends StatelessWidget {
  final String fsw;
  const SignWritingWidget({required this.fsw, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: signwritingToImage(
        fsw,
        trustBox: false,
        lineColor: Colors.deepOrange,
        fillColor: Colors.white,
      ),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else {
            return const Text('Failed to render SignWriting Image');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
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
        body: const Center(
          child: SignWritingWidget(
            fsw:
                "AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S20544510x500S10019476x475",
          ),
        ),
      ),
    );
  }
}
```

![result](https://github.com/user-attachments/assets/43fc87d3-39a0-4f7b-915a-5be173bccf06)

