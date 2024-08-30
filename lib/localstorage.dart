import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:bip39/bip39.dart' as bip39;

import 'models.dart';
import 'objectbox.g.dart';

class SingletonObjectboxData {
  SingletonObjectboxData.internal();
  static final _singleton = SingletonObjectboxData.internal();
  bool _isInitialized = false;
  late final Store _store;

  Future<void> initialize() async {
    _store = await _initObjectbox();
    _isInitialized = true;
  }

  Future<Store> _initObjectbox() async {
    final store = await openStore(
        directory:
            p.join((await getApplicationDocumentsDirectory()).path, "obx-db"));
    return store;
  }

  Store get store => _store;
  bool get isInitialized => _isInitialized;

  factory SingletonObjectboxData() {
    return _singleton;
  }
}

Store getStore() {
  return SingletonObjectboxData().store;
}

class SingletonMnemonicData {
  SingletonMnemonicData.internal();
  static final _singleton = SingletonMnemonicData.internal();
  bool _isInitialized = false;

  late final String _mnemonic;

  Future<void> initialize() async {
    _mnemonic = await _getMnemonic();
    _isInitialized = true;
  }

  Future<String> _getMnemonic() async {
    const storage = FlutterSecureStorage();
    String? mnemonic = await storage.read(key: 'mnemonic');
    if (mnemonic == null) {
      mnemonic = bip39.generateMnemonic();
      await storage.write(
        key: 'mnemonic',
        value: mnemonic,
      );
    }
    return mnemonic;
  }

  String get mnemonic => _mnemonic;
  bool get isInitialized => _isInitialized;

  factory SingletonMnemonicData() {
    return _singleton;
  }
}

Future<String> getMnemonic() async {
  const storage = FlutterSecureStorage();
  String? mnemonic = await storage.read(key: 'mnemonic');
  if (mnemonic == null) {
    mnemonic = bip39.generateMnemonic();
    await storage.write(
      key: 'mnemonic',
      value: mnemonic,
    );
  }
  return mnemonic;
}

Future<String?> readFlutterSecureStorage({required String key}) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: key);
}

Future<void> writeFlutterSecureStorage(
    {required String key, required String value}) async {
  const storage = FlutterSecureStorage();
  await storage.write(
    key: key,
    value: value,
  );
}

// Future<void> initObjectbox() async {
//   store = await openStore(
//       directory:
//           p.join((await getApplicationDocumentsDirectory()).path, "obx-db"));
// }

void saveTokenAccount(TokenAccount tokenAccount) {
  final store = getStore();
  final tokenAccountBox = Box<TokenAccount>(store);

  try {
    tokenAccountBox.put(tokenAccount);
  } on UniqueViolationException catch (e) {}
}

TokenAccount? loadTokenAccount(String mint) {
  final store = getStore();

  final tokenAccountBox = Box<TokenAccount>(store);

  Query<TokenAccount> query =
      tokenAccountBox.query(TokenAccount_.mint.equals(mint)).build();
  List<TokenAccount> tokenAccountList = query.find();
  query.close();

  return tokenAccountList.isEmpty ? null : tokenAccountList.first;
}

List<TokenAccount> loadTokenAccountList() {
  final store = getStore();

  final tokenAccountBox = Box<TokenAccount>(store);

  final tokenAccounts = tokenAccountBox.getAll();

  return tokenAccounts;
}

void removeTokenAccount() {
  final store = getStore();

  final tokenAccountBox = Box<TokenAccountBalance>(store);

  tokenAccountBox.removeAll();
}

void saveTokenAccountBalance(TokenAccountBalance tokenAccountBalance) {
  final store = getStore();

  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  Query<TokenAccountBalance> query = tokenAccountBalanceBox
      .query(TokenAccountBalance_.pubkey.equals(tokenAccountBalance.pubkey!))
      .build();
  final tokenAccountBalanceList = query.find();
  if (tokenAccountBalanceList.isNotEmpty) {
    tokenAccountBalance.id = tokenAccountBalanceList.first.id;
  }
  query.close();

  try {
    tokenAccountBalanceBox.put(tokenAccountBalance);
  } on UniqueViolationException catch (e) {}
}

TokenAccountBalance? loadTokenAccountBalance(String pubkey) {
  final store = getStore();

  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  Query<TokenAccountBalance> query = tokenAccountBalanceBox
      .query(TokenAccountBalance_.pubkey.equals(pubkey))
      .build();
  List<TokenAccountBalance> tokenAccountBalanceList = query.find();
  query.close();

  return tokenAccountBalanceList.isEmpty ? null : tokenAccountBalanceList.first;
}

List<TokenAccountBalance> loadTokenAccountBalanceList() {
  final store = getStore();

  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  final tokenAccountBalances = tokenAccountBalanceBox.getAll();

  return tokenAccountBalances;
}

void removeTokenAccountBalance() {
  final store = getStore();

  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  tokenAccountBalanceBox.removeAll();
}

void saveTransactionInfo(TransactionInfo transactionInfo) {
  final store = getStore();

  final transactionInfoBox = Box<TransactionInfo>(store);

  try {
    transactionInfoBox.put(transactionInfo);
  } on UniqueViolationException catch (e) {}
}

bool isSameSignature(String signature) {
  final store = getStore();

  final transactionInfoBox = Box<TransactionInfo>(store);

  final query = transactionInfoBox
      .query(TransactionInfo_.signature.equals(signature))
      .build();

  return query.find().isNotEmpty;
}

List<TransactionInfo> loadTransactionInfoList() {
  final store = getStore();

  final transactionInfoBox = Box<TransactionInfo>(store);

  final transactions = transactionInfoBox.getAll();

  return transactions;
}

void removeTransactionInfo() {
  final store = getStore();

  final transactionInfoBox = Box<TransactionInfo>(store);

  transactionInfoBox.removeAll();
}

void saveWhitelist(Whitelist whitelist) {
  final store = getStore();

  final whitelistBox = Box<Whitelist>(store);

  try {
    whitelistBox.put(whitelist);
  } on UniqueViolationException catch (e) {}
}

bool isSameWhitelist(String pubkey) {
  final store = getStore();

  final whitelistBox = Box<Whitelist>(store);

  final query = whitelistBox.query(Whitelist_.pubkey.equals(pubkey)).build();

  return query.find().isNotEmpty;
}

void removeWhitelist() {
  final store = getStore();

  final whitelistBox = Box<Whitelist>(store);

  whitelistBox.removeAll();
}

void saveItem(Item item) {
  final store = getStore();

  final itemBox = Box<Item>(store);

  try {
    itemBox.put(item);
  } on UniqueViolationException catch (e) {}
}

Item? loadItem(int id) {
  final store = getStore();

  final itemBox = Box<Item>(store);

  Query<Item> query = itemBox.query(Item_.id.equals(id)).build();
  List<Item> itemList = query.find();
  query.close();

  return itemList.isEmpty ? null : itemList.first;
}

List<Item> loadItemList() {
  final store = getStore();

  final itemBox = Box<Item>(store);

  final item = itemBox.getAll();

  return item;
}

void updateItem(Item item) {
  final store = getStore();

  final itemBox = Box<Item>(store);
  itemBox.putAndGetAsync(item);
}

void removeItem(int id) {
  final store = getStore();

  final itemBox = Box<Item>(store);
  itemBox.remove(id);
}

void removeItemList() {
  final store = getStore();

  final itemBox = Box<Item>(store);

  itemBox.removeAll();
}

void addCartItem(CartItem cartItem) {
  final store = getStore();

  final cartItemBox = Box<CartItem>(store);

  try {
    cartItemBox.put(cartItem);
  } on UniqueViolationException catch (e) {}
}

void removeCartItem(int itemID) {
  final store = getStore();

  final cartItemBox = Box<CartItem>(store);

  Query<CartItem> query =
      cartItemBox.query(CartItem_.itemID.equals(itemID)).build();
  List<CartItem> cartItem = query.find();
  query.close();

  if (cartItem.isNotEmpty) {
    try {
      cartItemBox.remove(cartItem.first.id);
    } on UniqueViolationException catch (e) {}
  }
}

int loadCartItemNum(int itemID) {
  final store = getStore();

  final cartItemBox = Box<CartItem>(store);

  Query<CartItem> query =
      cartItemBox.query(CartItem_.itemID.equals(itemID)).build();
  List<CartItem> cartItem = query.find();
  query.close();

  return cartItem.length;
}

List<CartItem> loadCartItemList() {
  final store = getStore();

  final cartItemBox = Box<CartItem>(store);

  final cartItem = cartItemBox.getAll();

  return cartItem;
}
