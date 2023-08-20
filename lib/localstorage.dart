import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:bip39/bip39.dart' as bip39;

import 'models.dart';
import 'objectbox.g.dart';

late final Store store;
late String publicKey;

Future<void> initMnemonic() async {
  const storage = FlutterSecureStorage();

  String? mnemonic = await storage.read(key: 'mnemonic');

  if (mnemonic == null) {
    mnemonic = bip39.generateMnemonic();
    await storage.write(
      key: 'mnemonic',
      value: mnemonic,
    );
  }
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

Future<void> initObjectbox() async {
  store = await openStore(
      directory:
          p.join((await getApplicationDocumentsDirectory()).path, "obx-db"));
}

void saveTokenAccount(TokenAccount tokenAccount) {
  final tokenAccountBox = Box<TokenAccount>(store);

  try {
    tokenAccountBox.put(tokenAccount);
  } on UniqueViolationException catch (e) {}
}

TokenAccount? loadTokenAccount(String mint) {
  final tokenAccountBox = Box<TokenAccount>(store);

  Query<TokenAccount> query =
      tokenAccountBox.query(TokenAccount_.mint.equals(mint)).build();
  List<TokenAccount> tokenAccountList = query.find();
  query.close();

  return tokenAccountList.isEmpty ? null : tokenAccountList.first;
}

List<TokenAccount> loadTokenAccountList() {
  final tokenAccountBox = Box<TokenAccount>(store);

  final tokenAccounts = tokenAccountBox.getAll();

  return tokenAccounts;
}

void removeTokenAccount() {
  final tokenAccountBox = Box<TokenAccountBalance>(store);

  tokenAccountBox.removeAll();
}

void saveTokenAccountBalance(TokenAccountBalance tokenAccountBalance) {
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
  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  Query<TokenAccountBalance> query = tokenAccountBalanceBox
      .query(TokenAccountBalance_.pubkey.equals(pubkey))
      .build();
  List<TokenAccountBalance> tokenAccountBalanceList = query.find();
  query.close();

  return tokenAccountBalanceList.isEmpty ? null : tokenAccountBalanceList.first;
}

List<TokenAccountBalance> loadTokenAccountBalanceList() {
  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  final tokenAccountBalances = tokenAccountBalanceBox.getAll();

  return tokenAccountBalances;
}

void removeTokenAccountBalance() {
  final tokenAccountBalanceBox = Box<TokenAccountBalance>(store);

  tokenAccountBalanceBox.removeAll();
}

void saveTransactionInfo(TransactionInfo transactionInfo) {
  final transactionInfoBox = Box<TransactionInfo>(store);

  try {
    transactionInfoBox.put(transactionInfo);
  } on UniqueViolationException catch (e) {}
}

bool isSameSignature(String signature) {
  final transactionInfoBox = Box<TransactionInfo>(store);

  final query = transactionInfoBox
      .query(TransactionInfo_.signature.equals(signature))
      .build();

  return query.find().isNotEmpty;
}

List<TransactionInfo> loadTransactionInfoList() {
  final transactionInfoBox = Box<TransactionInfo>(store);

  final transactions = transactionInfoBox.getAll();

  return transactions;
}

void removeTransactionInfo() {
  final transactionInfoBox = Box<TransactionInfo>(store);

  transactionInfoBox.removeAll();
}

void saveWhitelist(Whitelist whitelist) {
  final whitelistBox = Box<Whitelist>(store);

  try {
    whitelistBox.put(whitelist);
  } on UniqueViolationException catch (e) {}
}

bool isSameWhitelist(String pubkey) {
  final whitelistBox = Box<Whitelist>(store);

  final query = whitelistBox.query(Whitelist_.pubkey.equals(pubkey)).build();

  return query.find().isNotEmpty;
}

void removeWhitelist() {
  final whitelistBox = Box<Whitelist>(store);

  whitelistBox.removeAll();
}
