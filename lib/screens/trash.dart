import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localstorage.dart';
import '../provider.dart';

class Trash extends ConsumerWidget {
  const Trash({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
      ),
      body: ListView(
        children: const <Widget>[
          TrashList(),
        ],
      ),
    );
  }
}

class TrashList extends ConsumerWidget {
  const TrashList({super.key});

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
                return data[index].deleteAt != null
                    ? Card(
                        child: ExpansionTile(
                          title: Column(
                            children: [
                              Text(data[index].name.toString()),
                              Text(data[index].price.toString()),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              data[index].deleteAt = null;
                              updateItem(data[index]);
                            },
                            icon: const Icon(Icons.restore_from_trash),
                          ),
                          children: <Widget>[Text(data[index].memo.toString())],
                        ),
                      )
                    : Container();
              },
            );
          },
        );
  }
}
