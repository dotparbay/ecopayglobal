import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

import 'blockchain.dart';
import 'localstorage.dart';
import 'models.dart';
import 'objectbox.g.dart';

part 'provider.g.dart';

enum ViewType { home, pay, recive }

@riverpod
class BaseTabView extends _$BaseTabView {
  @override
  ViewType build() {
    return ViewType.home;
  }

  void changeType(int index) {
    state = ViewType.values[index];
  }
}

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
    final transactionInfoBox = Box<TransactionInfo>(store);

    final builder = transactionInfoBox
        .query(TransactionInfo_.blockTime.notNull())
      ..order(TransactionInfo_.blockTime, flags: Order.descending);
    return builder.watch(triggerImmediately: true).map((queqy) => queqy.find());
  }
}
