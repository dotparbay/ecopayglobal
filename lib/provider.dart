import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

import 'blockchain.dart';
import 'localstorage.dart';
import 'models.dart';
import 'objectbox.g.dart';

part 'provider.g.dart';

enum MainType { home, pay, recive }

enum MainStoreType { register, edit, trash, store, payment }

@riverpod
class BaseMainTabView extends _$BaseMainTabView {
  @override
  MainType build() {
    return MainType.home;
  }

  void changeType(int index) {
    state = MainType.values[index];
  }
}

@riverpod
class BaseMainStoreTabView extends _$BaseMainStoreTabView {
  @override
  MainStoreType build() {
    return MainStoreType.edit;
  }

  void changeType(int index) {
    state = MainStoreType.values[index];
  }
}

// @riverpod
// class GetPublicKeyUI extends _$GetPublicKeyUI {
//   @override
//   Future<String> build() async {
//     final keypair = getKeypair();
//     final publicKey = keypair.publicKey.toBase58();
//     return publicKey;
//   }
// }

@riverpod
class UpdateProgress extends _$UpdateProgress {
  @override
  Stream<double> build() async* {
    yield 0;
  }

  void updateBalanceDelayed() async {
    updateBalance();
    state = const AsyncValue.data(0.0);
    while (state.value! < 1.0) {
      state = AsyncValue.data(state.value! + 1 / 60);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> updateBalance() async {
    await Future.delayed(const Duration(seconds: 45));
    fetchSolBalance();
    await Future.delayed(const Duration(seconds: 3));
    fetchUSDTBalance();
  }
}

@riverpod
class FetchSolBalanceUI extends _$FetchSolBalanceUI {
  @override
  Future<String> build() async {
    final balance = await fetchSolBalance();
    return balance;
  }

  Future<String> fetchSolBalanceDelayed() async {
    await Future.delayed(const Duration(seconds: 60));
    final balance = await fetchSolBalance();
    return balance;
  }
}

@riverpod
class FetchUSDTBalanceUI extends _$FetchUSDTBalanceUI {
  @override
  Future<String> build() async {
    final balance = await fetchUSDTBalance();
    return balance;
  }

  Future<String> fetchUSDTBalanceDelayed() async {
    await Future.delayed(const Duration(seconds: 60));
    final balance = await fetchUSDTBalance();
    return balance;
  }
}

@riverpod
class LoadTransactionInfoListStreamUI
    extends _$LoadTransactionInfoListStreamUI {
  @override
  Stream<List<TransactionInfo>> build() {
    final store = getStore();

    final transactionInfoBox = Box<TransactionInfo>(store);

    final builder = transactionInfoBox
        .query(TransactionInfo_.blockTime.notNull())
      ..order(TransactionInfo_.blockTime, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((queqy) => queqy.find());
  }
}

@riverpod
class LoadItemListStreamUI extends _$LoadItemListStreamUI {
  @override
  Stream<List<Item>> build() {
    final store = getStore();

    final itemBox = Box<Item>(store);

    final builder = itemBox.query(Item_.id.notNull())
      ..order(Item_.id, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((queqy) => queqy.find());
  }
}

@riverpod
class LoadCartItemListStreamUI extends _$LoadCartItemListStreamUI {
  @override
  Stream<List<CartItem>> build() {
    final store = getStore();

    final itemBox = Box<CartItem>(store);

    final builder = itemBox.query(CartItem_.id.notNull())
      ..order(CartItem_.id, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((queqy) => queqy.find());
  }
}
