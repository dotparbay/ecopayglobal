import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

import 'blockchain.dart';
import 'localstorage.dart';
import 'models.dart';
import 'objectbox.g.dart';

part 'provider.g.dart';

enum ViewType { home, pay, recive }

// final baseTabViewProvider = StateProvider<ViewType>((ref) => ViewType.home);
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

// @riverpod
// class UpdateProgress extends _$UpdateProgress {
//   @override
//   double build() {
//     return 0.0;
//   }

//   Future<double> startUpdate() async {
//     print(startUpdate);
//     await Future.delayed(const Duration(seconds: 1));
//     // Timer.periodic(const Duration(seconds: 1), (Timer timer) {
//     if (state >= 1) {
//       // timer.cancel();
//       state = 0.0;
//     } else {
//       state = state + 0.1;
//     }
//     // });

//     return state;
//   }
// }

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
