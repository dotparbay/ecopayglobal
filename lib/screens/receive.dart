import 'package:flutter/material.dart';
import "dart:convert";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../blockchain.dart';
import '../localstorage.dart';

class Receive extends StatelessWidget {
  const Receive({super.key});

  @override
  Widget build(BuildContext context) {
    removeBalance();
    removeHistory();
    removeWhitelist();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: const Invoice(),
    );
  }
}

class Invoice extends StatefulWidget {
  const Invoice({super.key});

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  late TextEditingController _controllerAmount;

  bool isDouble = false;
  bool isPositive = true;
  String publicKey = "";
  @override
  Future<void> initState() async {
    super.initState();
    _controllerAmount = TextEditingController();
    final keypair = getKeypair();
    publicKey = keypair.publicKey.toBase58();
  }

  @override
  void dispose() {
    _controllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListView(
      children: [
        TextField(
          controller: _controllerAmount,
          onChanged: (value) {
            setState(() {});
            isDouble = double.tryParse(value) != null;
            if (isDouble) {
              isPositive = double.parse(value) >= 0;
            }
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
          ),
        ),
        ElevatedButton(
          onPressed: (_controllerAmount.text.isEmpty ||
                  !isDouble ||
                  !isPositive)
              ? null
              : () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CreateQR(
                      amount: _controllerAmount.text,
                    );
                  }));
                },
          child: const Text('OK'),
        ),
      ],
    ));
  }
}

class CreateQR extends ConsumerWidget {
  final String amount;
  final String memo;

  const CreateQR({
    super.key,
    required this.amount,
    this.memo = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, dynamic> qrMap = {};
    Map<String, dynamic> memoMap = {};

    var uuid = const Uuid();
    var v4 = uuid.v4();

    memoMap['id'] = v4;
    memoMap['memo'] = memo;

    qrMap['account'] = getKeypair().publicKey.toBase58();
    qrMap['amount'] = amount;
    qrMap['memo'] = memoMap;

    String account = qrMap['account'];
    String usdt = double.parse(qrMap['amount']).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive'),
      ),
      body: Card(
        child: ListView(
          children: [
            Column(
              children: <Widget>[
                Text(account),
                // Text(json.encode(qrMap)),
                QrImageView(data: json.encode(qrMap)),
                Text('\$$usdt(USDT)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
