import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signwriting_flutter/signwriting_flutter.dart';

void main() {
  runApp(const MyApp());
}

/// Renders any `Future<Uint8List>` PNG with a label.
class SignImage extends StatelessWidget {
  final String label;
  final Future<Uint8List> future;
  const SignImage({required this.label, required this.future, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        FutureBuilder<Uint8List>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator();
            }
            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return const Text(
                'Failed to render',
                style: TextStyle(color: Colors.red),
              );
            }
            return Image.memory(data);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // The same sign expressed as FSW and as SWU.
  static const fsw =
      'AS10011S10019S2e704S2e748M525x535S2e748483x510S10011501x466S20544510x500S10019476x475';
  static const swu = '𝠃𝤟𝤩񋛩𝣵𝤐񀀒𝤇𝣤񋚥𝤐𝤆񀀚𝣮𝣭';

  @override
  Widget build(BuildContext context) {
    const line = Colors.deepOrange;
    const fill = Colors.white;

    // A word fingerspelled with the re-exported `spell` utility, then rendered.
    final spelled = spell('abc', language: 'ase')!;

    return MaterialApp(
      title: 'SignWriting Flutter Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('SignWriting Flutter Example')),
        backgroundColor: Colors.black,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 1. A single FSW sign.
                SignImage(
                  label: 'FSW',
                  future: signwritingToImage(
                    fsw,
                    trustBox: false,
                    lineColor: line,
                    fillColor: fill,
                  ),
                ),
                // 2. The same sign from an SWU string (auto-converted).
                SignImage(
                  label: 'SWU (auto-converted)',
                  future: signwritingToImage(
                    swu,
                    trustBox: false,
                    lineColor: line,
                    fillColor: fill,
                  ),
                ),
                // 3. Several signs combined horizontally.
                SignImage(
                  label: 'Multiple signs (horizontal)',
                  future: signwritingsToImage(
                    const [
                      'M507x507S1f720487x492',
                      'M507x507S14720493x485',
                      'M508x507S16d20491x487',
                    ],
                    direction: SignWritingLayout.horizontal,
                    lineColor: line,
                    fillColor: fill,
                  ),
                ),
                // 4. A fingerspelled word ("abc") via the re-exported utility.
                SignImage(
                  label: 'Fingerspelled "abc"',
                  future: signwritingToImage(
                    spelled,
                    trustBox: false,
                    lineColor: line,
                    fillColor: fill,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
