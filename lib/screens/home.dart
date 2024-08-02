import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solana/solana.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../blockchain.dart';
import '../localstorage.dart';
import '../provider.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    convertUSDT();
    fetchHistory();
    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.store),
        //     onPressed: () {
        //       Navigator.push(context,
        //           MaterialPageRoute(builder: (context) => const MyStoreApp()));
        //     },
        //   ),
        // ],
      ),
      body: ListView(
        children: const <Widget>[
          Balance(),
          History(),
        ],
      ),
    );
  }
}

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: <Widget>[
            ListTile(
              // leading: const Icon(Icons.balance),
              title: const Column(
                children: [
                  Text('Balance'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$',
                      ),
                      USDTBalance(),
                      Text(
                        '(USDT)',
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Column(
                children: [
                  const UpdateBalance(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Row(
                          children: [
                            Text("Your Gas Balance:"),
                            SolBalance(),
                            Text("(sol)"),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () async {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "The transaction fee for Solana (SOL) is 0.000005 SOL per signature in the transaction. \n\nLow cost, forever Solana's scalability ensures transactions remain less than \$0.01 for both developers and users."),
                            ));
                          },
                        ),
                      ]),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Deposit'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Deposit()));
                  },
                ),
                ElevatedButton(
                  child: const Text('Withdraw'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Withdraw()));
                  },
                ),
                ElevatedButton(
                  child: const Text('Send'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Send()));
                  },
                ),
              ],
            ),
            TextButton(
              child: const Text('Pay it forward'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PayItFoward()));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class UpdateBalance extends ConsumerWidget {
  const UpdateBalance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(updateProgressProvider).when(
          loading: () {
            return IconButton(
              icon: const Icon(Icons.update),
              onPressed: () {
                ref
                    .read(updateProgressProvider.notifier)
                    .updateBalanceDelayed();
              },
            );
          },
          error: (error, stack) => const Text('error'),
          data: (data) {
            return Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.update),
                  onPressed: () {
                    ref
                        .read(updateProgressProvider.notifier)
                        .updateBalanceDelayed();
                  },
                ),
                LinearProgressIndicator(
                  value: data,
                ),
              ],
            );
          },
        );
  }
}

class SolBalance extends ConsumerWidget {
  const SolBalance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(fetchSolBalanceUIProvider).when(
          loading: () {
            return const Text('loading');
          },
          error: (error, stack) => const Text('error'),
          data: (data) {
            return Text(data);
          },
        );
  }
}

class USDTBalance extends ConsumerWidget {
  const USDTBalance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(fetchUSDTBalanceUIProvider).when(
        loading: () {
          String usdt = getUSDTBalance();
          return Text(usdt);
        },
        error: (error, stack) => const Text('error'),
        data: (data) {
          return Text(data);
        });
  }
}

class Deposit extends ConsumerWidget {
  const Deposit({super.key});

  void _onShare(BuildContext context, String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit SOL Account'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              convertUSDT();
              ref
                  .read(fetchSolBalanceUIProvider.notifier)
                  .fetchSolBalanceDelayed();
              ref
                  .read(fetchUSDTBalanceUIProvider.notifier)
                  .fetchUSDTBalanceDelayed();
              Navigator.pop(context);
            }),
      ),
      body: Card(
        child: ListView(
          children: [
            ListTile(
              leading: Image.network(
                SOL_LOGO_URL,
                fit: BoxFit.cover,
              ),
              title: const Text('SOL Account'),
              subtitle: const Text(
                  'Send SOL to your Account and wait a few minutes.'),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$'),
                USDTBalance(),
                Text('(USDT)'),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SolBalance(),
                Text('(SOL)'),
              ],
            ),
            Text(
              getKeypair().publicKey.toBase58(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            QrImageView(data: getKeypair().publicKey.toBase58()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _onShare(context, getKeypair().publicKey.toBase58());
                    Clipboard.setData(
                        ClipboardData(text: getKeypair().publicKey.toBase58()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Copied to clipboard! \n\nNote: When SOL is received, it is automatically converted to USDT.'),
                    ));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: getKeypair().publicKey.toBase58()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Copied to clipboard! \n\nNote: When SOL is received, it is automatically converted to USDT.'),
                    ));
                  },
                ),
              ],
            ),
            const Divider(),
            TextButton(
              child: const Text('Convert ETH to SOL'),
              onPressed: () {
                final Uri url = Uri.parse(
                    'https://app.rango.exchange/swap/ETH.ETH/SOLANA.SOL');
                launchUrl(url);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Withdraw extends ConsumerStatefulWidget {
  const Withdraw({super.key});

  @override
  ConsumerState<Withdraw> createState() => _WithdrawState();
}

class _WithdrawState extends ConsumerState<Withdraw> {
  late TextEditingController _controllerAccount;
  late TextEditingController _controllerAmount;

  bool isDouble = false;
  bool isPositive = false;

  @override
  void initState() {
    super.initState();
    _controllerAccount = TextEditingController();
    _controllerAmount = TextEditingController();
  }

  @override
  void dispose() {
    _controllerAccount.dispose();
    _controllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
      ),
      body: Card(
          child: ListView(
        children: [
          Tab(
            icon: SvgPicture.network(
              USDT_LOGO_URL,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator()),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$'),
              USDTBalance(),
              Text('(USDT)'),
            ],
          ),
          TextField(
            controller: _controllerAccount,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Account',
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final address = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReadAddress()),
                  );
                  if (address != null) {
                    _controllerAccount.text = address;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
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
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixIcon: TextButton(
                child: const Text('Max'),
                onPressed: () {
                  _controllerAmount.text = getUSDTBalance();
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: (_controllerAccount.text.isEmpty ||
                    _controllerAmount.text.isEmpty ||
                    !isDouble ||
                    !isPositive)
                ? null
                : () async {
                    Navigator.pop(context);

                    sendToken(
                      account: _controllerAccount.text,
                      amount: _controllerAmount.text,
                    ).then((signature) {
                      final Uri url =
                          Uri.parse('https://solscan.io/tx/$signature');
                      launchUrl(url);
                    });

                    ref
                        .read(fetchUSDTBalanceUIProvider.notifier)
                        .fetchUSDTBalanceDelayed();
                  },
            child: const Text('Withdraw'),
          ),
          const Text(
              'Note: It is important to double check the destination address of the USDT before withdrawing USDT; sending USDT outside the Solana network will result in loss of funds.'),
        ],
      )),
    );
  }
}

class Send extends ConsumerStatefulWidget {
  const Send({super.key});

  @override
  ConsumerState<Send> createState() => _SendState();
}

class _SendState extends ConsumerState<Send> {
  late TextEditingController _controllerAccount;
  late TextEditingController _controllerAmount;

  bool isDouble = false;
  bool isPositive = false;

  @override
  void initState() {
    super.initState();
    _controllerAccount = TextEditingController();
    _controllerAmount = TextEditingController();
  }

  @override
  void dispose() {
    _controllerAccount.dispose();
    _controllerAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send'),
      ),
      body: Card(
          child: ListView(
        children: [
          Tab(
            icon: SvgPicture.network(
              USDT_LOGO_URL,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator()),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$'),
              USDTBalance(),
              Text('(USDT)'),
            ],
          ),
          TextField(
            controller: _controllerAccount,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Account',
              suffixIcon: IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: () async {
                  final address = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ReadAddress()),
                  );
                  if (address != null) {
                    _controllerAccount.text = address;
                    setState(() {});
                  }
                },
              ),
            ),
          ),
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
            decoration: InputDecoration(
              labelText: 'Amount',
              suffixIcon: TextButton(
                child: const Text('Max'),
                onPressed: () {
                  _controllerAmount.text = getUSDTBalance();
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: (_controllerAccount.text.isEmpty ||
                    _controllerAmount.text.isEmpty ||
                    !isDouble ||
                    !isPositive)
                ? null
                : () async {
                    Navigator.pop(context);

                    sendToken(
                      account: _controllerAccount.text,
                      amount: _controllerAmount.text,
                    ).then((signature) {
                      final Uri url =
                          Uri.parse('https://solscan.io/tx/$signature');
                      launchUrl(url);
                    });

                    ref
                        .read(fetchUSDTBalanceUIProvider.notifier)
                        .fetchUSDTBalanceDelayed();
                  },
            child: const Text('Send'),
          ),
        ],
      )),
    );
  }
}

class PayItFoward extends ConsumerStatefulWidget {
  const PayItFoward({super.key});

  @override
  ConsumerState<PayItFoward> createState() => _PayItFowardState();
}

class _PayItFowardState extends ConsumerState<PayItFoward> {
  late TextEditingController _controllerAccount;

  @override
  void initState() {
    super.initState();
    _controllerAccount = TextEditingController();
  }

  @override
  void dispose() {
    _controllerAccount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay It Foward'),
      ),
      body: Card(
        child: ListView(
          children: [
            Tab(
              icon: Image.network(
                SOL_LOGO_URL,
                fit: BoxFit.contain,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SolBalance(),
                Text('(SOL)'),
              ],
            ),
            TextField(
              controller: _controllerAccount,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Account',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async {
                    final address = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReadAddress()),
                    );
                    if (address != null) {
                      _controllerAccount.text = address;
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (_controllerAccount.text.isEmpty)
                  ? null
                  : () async {
                      Navigator.pop(context);

                      payItfoward(account: _controllerAccount.text)
                          .then((signature) {
                        final Uri url =
                            Uri.parse('https://solscan.io/tx/$signature');
                        launchUrl(url);
                      });

                      ref
                          .read(fetchSolBalanceUIProvider.notifier)
                          .fetchSolBalanceDelayed();
                    },
              child: const Text('Send'),
            ),
            const Divider(),
            const Text(
                'Send 0.0003 sol. You can save your friends from running out of gas.'),
          ],
        ),
      ),
    );
  }
}

class History extends ConsumerWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loadTransactionInfoListStreamUIProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Text('error'),
          data: (data) {
            final tokenAccount = loadTokenAccount(USDT);
            if (tokenAccount == null) {
              return Container();
            }

            final pubkey = tokenAccount.pubkey;
            if (pubkey == null) {
              return Container();
            }
            final tokenAccountBalance = loadTokenAccountBalance(pubkey);
            if (tokenAccountBalance == null) {
              return Container();
            }

            final decimals = tokenAccountBalance.decimals;

            if (decimals == null) {
              return Container();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final transactionDetails =
                    jsonDecode(data[index].transactionDetails!);

                final tokenAccountPublicKey = tokenAccount.pubkey;
                final signature = data[index].signature;
                final blockTime = data[index].blockTime;
                final DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(blockTime! * 1000);
                final from = transactionDetails["from"];
                final to = transactionDetails["to"];
                final amount = (double.parse(transactionDetails["amount"]) /
                        pow(10, decimals))
                    .toString();
                final memo = transactionDetails["memo"];
                final id = transactionDetails["id"];
                return Card(
                  child: ExpansionTile(
                    leading: tokenAccountPublicKey.toString() == to.toString()
                        ? const Icon(Icons.add)
                        : const Icon(Icons.remove),
                    title: tokenAccountPublicKey.toString() == to.toString()
                        ? Text(
                            "\$$amount",
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            "-\$$amount",
                            textAlign: TextAlign.center,
                          ),
                    trailing: Text(
                      date.toIso8601String(),
                      textAlign: TextAlign.center,
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          final Uri url =
                              Uri.parse('https://solscan.io/tx/$signature');
                          launchUrl(url);
                        },
                        child: const Text("details"),
                      ),
                      Text(
                        "to:$to",
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "from:$from",
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      memo.toString().isNotEmpty
                          ? Text(
                              "memo:$memo",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Container(),
                      id != null
                          ? Text(
                              "id:$id",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Container(),
                    ],
                  ),
                );
              },
            );
          },
        );
  }
}

class ReadAddress extends StatelessWidget {
  const ReadAddress({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFound = false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read QR'),
      ),
      body: MobileScanner(onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        if (barcodes.isEmpty) {
          debugPrint('barcodes.isEmpty');
        } else if (isFound) {
          debugPrint('isFound');
        } else if (isValidAddress(barcodes.first.rawValue!)) {
          final String code = barcodes.first.rawValue!;
          debugPrint('Barcode found! $code');
          Navigator.pop(context, code);
          isFound = true;
        } else {}
      }),
    );
  }
}
