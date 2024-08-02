import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:url_launcher/url_launcher.dart';

import '../blockchain.dart';
import '../localstorage.dart';
import '../main.dart';
import '../provider.dart';

class Payment extends ConsumerWidget {
  const Payment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    convertUSDT();
    fetchHistory();
    return Scaffold(
      appBar: AppBar(
        title: const Text('payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const MyApp();
              }));
            },
          ),
        ],
      ),
      body: ListView(
        children: const <Widget>[
          History(),
        ],
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
                final cartItems = transactionDetails["cartItems"];
                Map<int, dynamic> itemMap = {};
                itemMap.toString();
                return cartItems.toString().isNotEmpty
                    ? Card(
                        child: ExpansionTile(
                          leading:
                              tokenAccountPublicKey.toString() == to.toString()
                                  ? const Icon(Icons.add)
                                  : const Icon(Icons.remove),
                          title:
                              tokenAccountPublicKey.toString() == to.toString()
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
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                final Uri url = Uri.parse(
                                    'https://solscan.io/tx/$signature');
                                launchUrl(url);
                              },
                              child: const Text("details"),
                            ),
                            Row(
                              children: [
                                const Text("to:"),
                                Text(
                                  to,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("from:"),
                                Text(
                                  from,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            memo.toString().isNotEmpty
                                ? Row(
                                    children: [
                                      const Text("memo:"),
                                      Text(
                                        memo,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : Container(),
                            id != null
                                ? Row(
                                    children: [
                                      const Text("id:"),
                                      Text(
                                        id,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  )
                                : Container(),
                            cartItems != null
                                ? Row(
                                    children: [
                                      const Text("cartItems:"),
                                      Text(
                                        cartItems,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : Container();
              },
            );
          },
        );
  }
}
