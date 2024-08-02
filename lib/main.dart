import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'blockchain.dart';
import 'screens/home.dart';
import 'screens/pay.dart';
import 'provider.dart';
import 'screens/recive.dart';

import 'localstorage.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SingletonObjectboxData().initialize();
  await SingletonKeypairData().initialize();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Bank',
      home: BaseTabView(),
    );
  }
}

class BaseTabView extends ConsumerWidget {
  BaseTabView({super.key});

  final widgets = [
    const Home(),
    const Pay(),
    const Recive(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FlutterNativeSplash.remove();
    final view = ref.watch(baseMainTabViewProvider);
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
            ref.read(baseMainTabViewProvider.notifier).changeType(index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
