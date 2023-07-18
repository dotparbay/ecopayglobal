import 'package:flutter/material.dart';
import "dart:convert";
import 'package:uuid/uuid.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../blockchain.dart';

class Recive extends StatelessWidget {
  const Recive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // removeBalance();
    // removeHistory();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recive'),
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

  @override
  void initState() {
    super.initState();
    _controllerAmount = TextEditingController();
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
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
          onSubmitted: ((String value) {
            if (value.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return CreateQR(
                      amount: _controllerAmount.text,
                    );
                  },
                ),
              );
            }
          }),
        ),
        ElevatedButton(
          onPressed: _controllerAmount.text.isEmpty
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

class CreateQR extends StatelessWidget {
  final String amount;
  final String memo;

  const CreateQR({
    Key? key,
    required this.amount,
    this.memo = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> qrMap = {};
    Map<String, dynamic> memoMap = {};

    var uuid = const Uuid();
    var v4 = uuid.v4();

    memoMap['id'] = v4;
    memoMap['memo'] = memo;

    qrMap['account'] = getPublicKey();
    qrMap['amount'] = amount;
    qrMap['memo'] = memoMap;

    String account = qrMap['account'];
    String usdt = double.parse(qrMap['amount']).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recive'),
      ),
      body: Card(
        child: Column(
          children: [
            Column(
              children: <Widget>[
                Text(account),
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
