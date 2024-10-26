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
