import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/trash.dart';
import 'screens/edit.dart';
import 'screens/payment.dart';
import 'screens/store.dart';
import 'screens/register.dart';

import 'provider.dart';

class MyStoreApp extends StatelessWidget {
  const MyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Bank Store',
      home: BaseTabView(),
    );
  }
}

class BaseTabView extends ConsumerWidget {
  BaseTabView({super.key});

  final widgets = [
    const Register(),
    const Edit(),
    const Trash(),
    const Store(),
    const Payment(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(baseMainStoreTabViewProvider);
    return Scaffold(
      body: widgets[view.index],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.app_registration_rounded), label: 'register'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'edit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restore_from_trash), label: 'trash'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'store'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'payment'),
        ],
        currentIndex: view.index,
        onTap: (int index) =>
            ref.read(baseMainStoreTabViewProvider.notifier).changeType(index),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
