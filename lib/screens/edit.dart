import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localstorage.dart';
import '../models.dart';
import '../provider.dart';

class Edit extends ConsumerWidget {
  const Edit({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: ListView(
        children: const <Widget>[
          EditList(),
        ],
      ),
    );
  }
}

class EditList extends ConsumerWidget {
  const EditList({super.key});

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
                        child: ExpansionTile(
                          leading: IconButton(
                            onPressed: () async {
                              data[index].deleteAt =
                                  DateTime.now().millisecondsSinceEpoch;
                              updateItem(data[index]);
                              removeCartItem(data[index].id);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          title: Column(
                            children: [
                              Text(data[index].name.toString()),
                              Text(data[index].price.toString()),
                            ],
                          ),
                          trailing: IconButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return UpdateItem(
                                      id: data[index].id,
                                    );
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
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

class UpdateItem extends StatelessWidget {
  final int id;

  const UpdateItem({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: EditItem(
        id: id,
      ),
    );
  }
}

class EditItem extends StatefulWidget {
  final int id;

  const EditItem({
    super.key,
    required this.id,
  });
  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  late TextEditingController _controllerName;
  late TextEditingController _controllerPrice;
  late TextEditingController _controllerCategory;
  late TextEditingController _controllerMemo;
  late TextEditingController _controllerURL;
  late TextEditingController _controllerImage;
  late TextEditingController _controllerDeleteAt;

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController();
    _controllerPrice = TextEditingController();
    _controllerCategory = TextEditingController();
    _controllerMemo = TextEditingController();
    _controllerURL = TextEditingController();
    _controllerImage = TextEditingController();
    _controllerDeleteAt = TextEditingController();

    final item = loadItem(widget.id);
    if (item != null) {
      _controllerName.text = item.name ?? "";
      _controllerPrice.text = item.price ?? "";
      _controllerCategory.text = item.category ?? "";
      _controllerMemo.text = item.memo ?? "";
      _controllerURL.text = item.url ?? "";
      _controllerImage.text = item.image ?? "";
      _controllerDeleteAt.text = item.deleteAt != null
          ? DateTime.fromMillisecondsSinceEpoch(item.deleteAt!).toString()
          : "";
    }
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerPrice.dispose();
    _controllerCategory.dispose();
    _controllerMemo.dispose();
    _controllerURL.dispose();
    _controllerImage.dispose();
    _controllerDeleteAt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListView(
      children: [
        TextField(
          controller: _controllerName,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        TextField(
          controller: _controllerPrice,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        TextField(
          controller: _controllerCategory,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Category',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        TextField(
          controller: _controllerMemo,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Memo',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        TextField(
          controller: _controllerURL,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'URL',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        TextField(
          controller: _controllerImage,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Image',
          ),
          onChanged: ((String value) {
            setState(() {});
          }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _controllerDeleteAt.text.isNotEmpty
                ? Text('DeleteAt : ${_controllerDeleteAt.text}')
                : Container(),
            IconButton(
              onPressed: _controllerDeleteAt.text.isNotEmpty
                  ? () {
                      _controllerDeleteAt.clear();
                    }
                  : null,
              icon: const Icon(Icons.restore_from_trash),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: _controllerName.text.isEmpty ||
                      _controllerPrice.text.isEmpty
                  ? null
                  : () {
                      final item = Item(
                        id: widget.id,
                        name: _controllerName.text,
                        price: _controllerPrice.text,
                        category: _controllerCategory.text,
                        memo: _controllerMemo.text,
                        url: _controllerURL.text,
                        image: _controllerImage.text,
                        deleteAt: _controllerDeleteAt.text.isNotEmpty
                            ? int.parse(_controllerDeleteAt.text)
                            : null,
                      );
                      updateItem(item);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("update item"),
                      ));

                      Navigator.of(context).pop();
                    },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ],
    ));
  }
}
