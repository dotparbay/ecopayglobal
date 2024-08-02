import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../blockchain.dart' show sendToken;
import '../localstorage.dart';
import '../models.dart';

class Pay extends StatelessWidget {
  const Pay({super.key});

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
              debugPrint('code not json $code');
              return;
            }

            if (codeMap['account'] == null || codeMap['amount'] == null) {
              debugPrint('account not found! $code');
              return;
            }

            final account = codeMap['account'].toString();
            final amount = codeMap['amount'].toString();
            final memo = codeMap['memo'];

            isPaying = true;
            if (!isSameWhitelist(account)) {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    account: account,
                    amount: amount,
                    memo: json.encode(memo),
                  );
                },
              ).then(
                (isPay) async {
                  if (!isPay) {
                    debugPrint('is not Pay $isPay');
                  } else {
                    sendToken(
                            account: account,
                            amount: amount,
                            memo: json.encode(memo))
                        .then((signature) {
                      final Uri url =
                          Uri.parse('https://solscan.io/tx/$signature');
                      launchUrl(url);
                    });

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return Payed(
                              account: account,
                              amount: amount,
                              memo: json.encode(memo));
                        },
                      ),
                    );
                  }
                },
              );
            } else {
              debugPrint('is isSameWhitelist!!');
              sendToken(
                      account: account, amount: amount, memo: json.encode(memo))
                  .then((signature) {
                final Uri url = Uri.parse('https://solscan.io/tx/$signature');
                launchUrl(url);
              });

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Payed(
                        account: account,
                        amount: amount,
                        memo: json.encode(memo));
                  },
                ),
              );
            }

            debugPrint('is done!!');
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
    required this.account,
    required this.amount,
    this.memo = '',
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

class CustomDialog extends StatefulWidget {
  final String account;
  final String amount;
  final String memo;

  const CustomDialog({
    super.key,
    required this.account,
    required this.amount,
    this.memo = '',
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  bool _isChecked = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Do you want to pay?'),
      content: Column(
        children: [
          Text(
            widget.account,
          ),
          Text(
            '\$${widget.amount}(USDT)',
          ),
          const Divider(),
          Text(
            widget.memo,
          ),
          const Text(
            'Check this address again next time?',
          ),
          Row(
            children: [
              const Text(
                'YES',
              ),
              Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            if (!_isChecked) {
              final whitelist = Whitelist(pubkey: widget.account);
              saveWhitelist(whitelist);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
