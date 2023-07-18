import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../blockchain.dart' show sendToken;

class Pay extends StatelessWidget {
  const Pay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPaying = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('pay'),
      ),
      body: MobileScanner(
        onDetect: (capture) async {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) {
            debugPrint('barcodes.isEmpty');
          } else if (isPaying) {
            debugPrint('isPaying');
          } else {
            final String code = barcodes.first.rawValue!;
            debugPrint('Barcode found! $code');
            Map<String, dynamic> codeMap = {};
            try {
              codeMap = jsonDecode(code);
            } catch (e) {
              print(e);
              debugPrint('code not json $code');
              return;
            }

            if (codeMap['account'] == null || codeMap['amount'] == null) {
              debugPrint('account not found! $code');
              return;
            }

            isPaying = true;

            final account = codeMap['account'].toString();
            final amount = codeMap['amount'].toString();
            final memo = codeMap['memo']['memo'] == null
                ? ''
                : codeMap['memo']['memo'].toString();

            sendToken(account: account, amount: amount, memo: memo)
                .then((signature) {
              final Uri url = Uri.parse('https://solscan.io/tx/$signature');
              launchUrl(url);
            });

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return Payed(account: account, amount: amount, memo: memo);
                },
              ),
            );
            isPaying = false;
          }
        },
      ),
    );
  }
}

class Payed extends StatelessWidget {
  final String account;
  final String amount;
  final String memo;

  const Payed({
    Key? key,
    required String this.account,
    required String this.amount,
    String this.memo = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total'),
      ),
      body: Column(
        children: <Widget>[
          Text('\$$amount(USDT)'),
          Text(memo),
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
