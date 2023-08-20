import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home.dart';
import 'screens/pay.dart';
import 'provider.dart';
import 'screens/recive.dart';

import 'blockchain.dart';
import 'localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initMnemonic();
  await setPublicKey();
  await initObjectbox();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Bank',
      home: BaseTabView(),
    );
  }
}

class BaseTabView extends ConsumerWidget {
  BaseTabView({Key? key}) : super(key: key);

  final widgets = [
    const Home(),
    const Pay(),
    const Recive(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(baseTabViewProvider);
    return Scaffold(
      body: widgets[view.index],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'pay'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'recive'),
        ],
        currentIndex: view.index,
        onTap: (int index) =>
            ref.read(baseTabViewProvider.notifier).changeType(index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
