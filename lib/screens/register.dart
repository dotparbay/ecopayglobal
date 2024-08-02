import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import '../localstorage.dart';

import '../models.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: const RegisterItem(),
    );
  }
}

class RegisterItem extends StatefulWidget {
  const RegisterItem({super.key});

  @override
  State<RegisterItem> createState() => _RegisterItemState();
}

class _RegisterItemState extends State<RegisterItem> {
  File? image;
  final picker = ImagePicker();

  late TextEditingController _controllerName;
  late TextEditingController _controllerPrice;
  late TextEditingController _controllerCategory;
  late TextEditingController _controllerMemo;
  late TextEditingController _controllerURL;
  late TextEditingController _controllerImage;

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController();
    _controllerPrice = TextEditingController();
    _controllerCategory = TextEditingController();
    _controllerMemo = TextEditingController();
    _controllerURL = TextEditingController();
    _controllerImage = TextEditingController();
  }

  @override
  void dispose() {
    _controllerName.dispose();
    _controllerPrice.dispose();
    _controllerCategory.dispose();
    _controllerMemo.dispose();
    _controllerURL.dispose();
    _controllerImage.dispose();
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
        IconButton(
          onPressed: () async {
            final XFile? image =
                await picker.pickImage(source: ImageSource.gallery);
            if (image == null) return;

            _controllerImage.text = image.path;
          },
          icon: const Icon(Icons.photo_library),
        ),
        ElevatedButton(
          onPressed:
              _controllerName.text.isEmpty || _controllerPrice.text.isEmpty
                  ? null
                  : () {
                      final item = Item(
                          name: _controllerName.text,
                          price: _controllerPrice.text,
                          category: _controllerCategory.text,
                          memo: _controllerMemo.text,
                          url: _controllerURL.text,
                          image: _controllerImage.text);
                      saveItem(item);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("add item"),
                      ));

                      _controllerName.clear();
                      _controllerPrice.clear();
                      _controllerCategory.clear();
                      _controllerMemo.clear();
                      _controllerURL.clear();
                      _controllerImage.clear();
                    },
          child: const Text('Register'),
        ),
      ],
    ));
  }
}
