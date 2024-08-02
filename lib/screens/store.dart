import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../blockchain.dart';

import 'dart:io';
import "dart:convert";
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:qr_flutter/qr_flutter.dart';

import '../localstorage.dart';
import '../models.dart';
import '../provider.dart';

class Store extends ConsumerWidget {
  const Store({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
      ),
      body: ListView(
        children: const <Widget>[
          ItemList(),
          Order(),
        ],
      ),
    );
  }
}

class ItemList extends ConsumerWidget {
  const ItemList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loadItemListStreamUIProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const Text('error'),
          data: (data) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return data[index].deleteAt == null
                    ? Card(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (data[index].url.toString() != "") {
                                  final Uri url =
                                      Uri.parse(data[index].url.toString());
                                  launchUrl(url);
                                }
                              },
                              icon: data[index].image.toString() == ""
                                  ? const Icon(Icons.image)
                                  : Image.file(
                                      File(data[index].image.toString()),
                                      fit: BoxFit.fitHeight,
                                    ),
                            ),
                            Column(
                              children: [
                                Text(data[index].name.toString()),
                                Text(data[index].price.toString()),
                              ],
                            ),
                            Row(
                              children: [
                                TextButton(
                                    onPressed: () {
                                      removeCartItem(data[index].id);
                                    },
                                    child: const Text("-")),
                                // Text(loadCartItemNum(data[index].id).toString()),
                                CartItemNumber(
                                  itemID: data[index].id,
                                ),
                                TextButton(
                                    onPressed: () {
                                      final cartItem =
                                          CartItem(itemID: data[index].id);
                                      addCartItem(cartItem);
                                    },
                                    child: const Text("+")),
                              ],
                            ),
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

class CartItemNumber extends ConsumerWidget {
  final int itemID;

  const CartItemNumber({
    super.key,
    required this.itemID,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loadCartItemListStreamUIProvider).when(
        loading: () {
          return const Text('0');
        },
        error: (error, stack) => const Text('error'),
        data: (data) {
          final count = data
              .where((CartItem? value) => value?.itemID == itemID)
              .toList()
              .length;

          return Text(count.toString());
        });
  }
}

class Order extends ConsumerWidget {
  const Order({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(loadCartItemListStreamUIProvider).when(
        loading: () {
          return const Text('0');
        },
        error: (error, stack) => const Text('error'),
        data: (data) {
          final count = data.toList().length;

          return IconButton(
              onPressed: count == 0
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const CreateQR();
                          },
                        ),
                      );
                    },
              icon: const Icon(Icons.shopping_cart));
        });
  }
}

class CreateQR extends ConsumerWidget {
  const CreateQR({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<int, dynamic> itemMap = {};
    Map<String, dynamic> qrMap = {};
    Map<String, dynamic> memoMap = {};

    final cartItemList = loadCartItemList();

    final itemIDs = <dynamic>{};
    cartItemList.retainWhere((x) => itemIDs.add(x.itemID));

    double amount = 0.0;
    for (final itemID in itemIDs) {
      final item = loadItem(itemID);
      if (item == null) {
        removeCartItem(itemID);
        continue;
      }
      final itemNum = loadCartItemNum(itemID);
      itemMap[itemID] = itemNum;
      amount = amount + double.parse(item.price!) * itemNum;
    }

    String memo = '';
    var uuid = const Uuid();
    var v4 = uuid.v4();

    memoMap['id'] = v4;
    memoMap['cartItems'] = itemMap.toString();
    memoMap['memo'] = memo;

    qrMap['account'] = getKeypair().publicKey.toBase58();
    qrMap['amount'] = amount.toString();
    qrMap['memo'] = memoMap;

    String account = qrMap['account'];
    String usdt = double.parse(qrMap['amount']).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
      ),
      body: Card(
        child: Column(
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
