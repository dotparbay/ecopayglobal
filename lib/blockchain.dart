import 'dart:math';
import "dart:convert";
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';

import 'package:solana/solana.dart';
import 'package:solana/src/rpc/dto/raw_instruction.dart';
import 'package:solana/src/encoder/message_header.dart';

import 'package:uuid/uuid.dart';

import './models.dart';
import 'localstorage.dart';

const rpcurlList = [
  // 'https://rpc.ankr.com/solana',
  'https://api.mainnet-beta.solana.com',
  'https://try-rpc.mainnet.solana.blockdaemon.tech',
];

const SOL = 'So11111111111111111111111111111111111111112';
const USDT = 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB';
const SOL_LOGO_URL =
    'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png';
const USDT_LOGO_URL =
    'https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB/logo.svg';

late String publicKey;
List<String?> fetchingTransactionList = [];

Future<void> setPublicKey() async {
  String? mnemonic = await readFlutterSecureStorage(key: 'mnemonic');
  final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic!);
  publicKey = keypair.publicKey.toBase58();
}

String getPublicKey() {
  return publicKey;
}

Future<Ed25519HDKeyPair> getKeypair() async {
  String? mnemonic = await readFlutterSecureStorage(key: 'mnemonic');
  final keypair = await Ed25519HDKeyPair.fromMnemonic(mnemonic!);
  return keypair;
}

String getSOLBalance() {
  final tokenAccountBalance = loadTokenAccountBalance(getPublicKey());

  if (tokenAccountBalance == null) {
    return '0';
  }

  return tokenAccountBalance.uiAmountString ?? '0';
}

String getUSDTBalance() {
  final tokenAccount = loadTokenAccount(USDT);

  if (tokenAccount == null) {
    return '0';
  }
  final pubkey = tokenAccount.pubkey;

  if (pubkey == null) {
    return '0';
  }
  final tokenAccountBalance = loadTokenAccountBalance(pubkey);

  if (tokenAccountBalance == null) {
    return '0';
  }

  final uiAmountString = tokenAccountBalance.uiAmountString;

  if (uiAmountString == null) {
    return '0';
  }

  return double.parse(uiAmountString).toStringAsFixed(2);
}

void removeBalance() {
  print("removeBalance");
  removeTokenAccount();
  removeTokenAccountBalance();
}

void removeHistory() {
  print("removeHistory");
  removeTransactionInfo();
}

Future<String> fetchSolBalance() async {
  print("fetchSolBalance");
  final source = await getKeypair();
  final random = Random();
  final rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  final rpcClient = RpcClient(rpcurl);
  final balance = await rpcClient.getBalance(
    source.address,
  );

  final tokenAccountBalance = TokenAccountBalance(
      pubkey: getPublicKey(),
      amount: balance.value.toString(),
      decimals: solDecimalPlaces,
      uiAmountString: (balance.value / lamportsPerSol).toString());
  saveTokenAccountBalance(tokenAccountBalance);

  return tokenAccountBalance.uiAmountString ?? '0';
}

Future<String> fetchUSDTBalance() async {
  print("fetchUSDTBalance");
  final tokenAccount = loadTokenAccount(USDT);
  if (tokenAccount == null) {
    fetchTokenAccount();
    return '0';
  }

  final pubkey = tokenAccount.pubkey;

  if (pubkey == null) {
    return '0';
  }

  final tokenAccountBalance = await fetchTokenAccountBalance(pubkey);

  final uiAmountString = tokenAccountBalance.uiAmountString;

  if (uiAmountString == null) {
    return '0';
  }

  return double.parse(uiAmountString).toStringAsFixed(2);
}

Future<void> fetchTokenAccount() async {
  final source = await getKeypair();
  final random = Random();
  final rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  print(rpcurl);
  final rpcClient = RpcClient(rpcurl);

  final accounts = await rpcClient.getTokenAccountsByOwner(
    source.address,
    const TokenAccountsFilter.byProgramId(TokenProgram.programId),
    encoding: Encoding.jsonParsed,
  );

  await Future.forEach(accounts.value, (account) async {
    final data = account.account.data;
    final programData = data as ParsedSplTokenProgramAccountData;
    final parsed = programData.parsed as TokenAccountData;
    final mint = parsed.info.mint;

    final tokenAccount = TokenAccount(pubkey: account.pubkey, mint: mint);
    saveTokenAccount(tokenAccount);
  });
}

Future<TokenAccountBalance> fetchTokenAccountBalance(String pubkey) async {
  final random = Random();
  final rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  print(rpcurl);
  final rpcClient = RpcClient(rpcurl);

  final tokenAmountResult = await rpcClient.getTokenAccountBalance(
    pubkey,
  );

  final tokenAccountBalance = TokenAccountBalance(
      pubkey: pubkey,
      amount: tokenAmountResult.value.amount,
      decimals: tokenAmountResult.value.decimals,
      uiAmountString: tokenAmountResult.value.uiAmountString);
  saveTokenAccountBalance(tokenAccountBalance);

  return tokenAccountBalance;
}

Future<void> fetchHistory() async {
  print("fetchHistory");

  fetchReceivedHistory();
  fetchSendHistory();
}

Future<void> fetchReceivedHistory() async {
  final tokenAccount = loadTokenAccount(USDT);
  if (tokenAccount == null) {
    return;
  }
  final pubkey = tokenAccount.pubkey;

  if (pubkey == null) {
    return;
  }

  await fetchTransactions(pubkey);
}

Future<void> fetchSendHistory() async {
  final source = await getKeypair();
  await fetchTransactions(source.address);
}

bool isFetchingTransaction(String signature) {
  print("fetchingTransactionList.length");
  print(fetchingTransactionList.length);
  if (fetchingTransactionList.length > 5) {
    print(fetchingTransactionList.first);
    fetchingTransactionList.removeAt(0);
  }
  if (fetchingTransactionList.contains(signature)) {
    return true;
  } else {
    fetchingTransactionList.add(signature);
    return false;
  }
}

bool isFetchedTransaction(String signature) {
  final exists = isSameSignature(signature);
  // final exists = transactionInfoList
  //     .any((transactionInfo) => transactionInfo.signature == signature);
  return exists;
}

Future<void> fetchTransactions(String pubKey) async {
  print("fetchTransactions");
  print(pubKey);

  final transactionSignatureInformationList =
      await fetchSignaturesForAddress(pubKey);

  await Future.forEach(
    transactionSignatureInformationList,
    (transactionSignatureInformation) async {
      print(transactionSignatureInformationList.length);
      print(transactionSignatureInformation.signature);
      print("fetch 10 transactionSignatureInformation");
      await Future.delayed(Duration(seconds: Random().nextInt(10) + 10));
      if (isFetchingTransaction(transactionSignatureInformation.signature)) {
        print("isFetchingTransaction");
        print(transactionSignatureInformation.signature);
        return;
      }
      if (isFetchedTransaction(transactionSignatureInformation.signature)) {
        print("isFetchedTransaction");
        print(transactionSignatureInformation.signature);
        return;
      }
      Map<String, String> transactionDetailMap = {};
      final random = Random();
      var rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
      final rpcClient = RpcClient(rpcurl);

      if (transactionSignatureInformation.confirmationStatus !=
          Commitment.finalized) {
        // print(
        //     "transactionSignatureInformationList[i].confirmationStatus != Commitment.finalized");
        // print(transactionSignatureInformationList[i].confirmationStatus);
        return;
      }

      print("rpcClient.getTransaction");
      final transactionDetail = await rpcClient.getTransaction(
        transactionSignatureInformation.signature,
      );

      if (transactionDetail == null) {
        final transactionInfo = TransactionInfo(
          signature: transactionSignatureInformation.signature,
        );

        saveTransactionInfo(transactionInfo);
        return;
      }
      // print(transactionSignatureInformationList[i].signature);
      // print(transactionDetail.blockTime);

      final parsedTransaction =
          transactionDetail.transaction as ParsedTransaction;
      if (parsedTransaction.message.instructions.isEmpty) {
        print("parsedTransaction.message.instructions.isEmpty");
        // print(parsedTransaction.message.instructions.isEmpty);
        // print(parsedTransaction.message.instructions);
        final transactionInfo = TransactionInfo(
          signature: transactionSignatureInformation.signature,
        );

        saveTransactionInfo(transactionInfo);
        return;
      }
      final rawInstruction =
          parsedTransaction.message.instructions.first as RawInstruction;
      // print(rawInstruction);
      // print(parsedTransaction
      //     .message.accountKeys[rawInstruction.programIdIndex].pubkey);

      final programIdIndex = parsedTransaction
          .message.accountKeys[rawInstruction.programIdIndex].pubkey;
      // print(programIdIndex);
      // print(TokenProgram.id.toBase58());
      if (programIdIndex != TokenProgram.id.toBase58()) {
        print("programIdIndex != TokenProgram.id.toBase58()");
        print(programIdIndex);
        print(TokenProgram.id.toBase58());
        final transactionInfo = TransactionInfo(
          signature: transactionSignatureInformation.signature,
        );

        saveTransactionInfo(transactionInfo);
        return;
      }

      final transferInstructionIndex = TokenProgram.transferInstructionIndex;
      final rawInstructionData = base58decode(rawInstruction.data);
      final instructionIndex = rawInstructionData.first;
      final amount = rawInstructionData.sublist(1);
      if (transferInstructionIndex.toList().first != instructionIndex) {
        print("transferInstructionIndex.toList().first != instructionIndex");
        // print(transferInstructionIndex.toList().first);
        // print(instructionIndex);

        final transactionInfo = TransactionInfo(
          signature: transactionSignatureInformation.signature,
        );

        saveTransactionInfo(transactionInfo);
        return;
      }
      Uint8List uintList = Uint8List.fromList(amount);
      int decimalValue =
          ByteData.view(uintList.buffer).getInt64(0, Endian.little);
      // print(decimalValue);
      transactionDetailMap['from'] = parsedTransaction
          .message.accountKeys[rawInstruction.accounts[0]].pubkey;
      transactionDetailMap['to'] = parsedTransaction
          .message.accountKeys[rawInstruction.accounts[1]].pubkey;
      transactionDetailMap['amount'] = decimalValue.toString();

      if (transactionSignatureInformation.memo != null) {
        final startIndex =
            transactionSignatureInformation.memo.toString().indexOf('{');
        final memo = jsonDecode(transactionSignatureInformation.memo
            .toString()
            .substring(startIndex));

        transactionDetailMap['id'] = memo['id'].toString();
        transactionDetailMap['memo'] =
            memo['memo'] == null ? '' : memo['memo'].toString();
      }

      final transactionInfo = TransactionInfo(
        signature: transactionSignatureInformation.signature,
        slot: transactionSignatureInformation.slot,
        err: json.encode(transactionSignatureInformation.err),
        memo: transactionSignatureInformation.memo,
        blockTime: transactionSignatureInformation.blockTime,
        confirmationStatus: transactionSignatureInformation.confirmationStatus,
        transactionDetails: json.encode(transactionDetailMap),
      );
      saveTransactionInfo(transactionInfo);
    },
  );
}

Future<List<TransactionSignatureInformation>> fetchSignaturesForAddress(
    String pubKey) async {
  final random = Random();
  var rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  final rpcClient = RpcClient(rpcurl);

  final transactionSignatureInformationList =
      await rpcClient.getSignaturesForAddress(
    pubKey,
  );

  return transactionSignatureInformationList;
}

Future<String> sendToken(
    {required String account,
    required String amount,
    String token = USDT,
    String memo = '',
    SignatureCallback? onSigned}) async {
  final mint = Ed25519HDPublicKey.fromBase58(token);
  final destination = Ed25519HDPublicKey.fromBase58(account);
  final owner = await getKeypair();

  const encoding = Encoding.jsonParsed;
  const commitment = Commitment.confirmed;
  final random = Random();
  var rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  final rpcClient = RpcClient(rpcurl);

  Map<String, String> memoMap = {};

  var uuid = const Uuid();
  var v4 = uuid.v4();

  memoMap['id'] = v4;
  memoMap['memo'] = '';

  final maxMemoLength = 566 - json.encode(memoMap).length;

  if (maxMemoLength < memo.length) {
    memoMap['memo'] = memo.substring(0, maxMemoLength);
  }

  var associatedRecipientAccount = await rpcClient.getTokenAccountsByOwner(
    destination.toBase58(),
    TokenAccountsFilter.byMint(token),
    encoding: encoding,
    commitment: commitment,
  );

  final associatedSenderAccount = await rpcClient.getTokenAccountsByOwner(
    owner.address,
    TokenAccountsFilter.byMint(token),
    encoding: encoding,
    commitment: commitment,
  );

  // Throw an appropriate exception if the sender has no associated
  // token account
  if (associatedSenderAccount.value.isEmpty) {
    throw NoAssociatedTokenAccountException(owner.address, mint.toBase58());
  }
  // Also throw an adequate exception if the recipient has no associated
  // token account
  if (associatedRecipientAccount.value.isEmpty) {
    await createAssociatedTokenAccount(
        owner: destination, mint: mint, funder: owner);

    int i = 0;
    while (i < 32) {
      await Future.delayed(const Duration(seconds: 1), () {});

      associatedRecipientAccount = await rpcClient.getTokenAccountsByOwner(
        destination.toBase58(),
        TokenAccountsFilter.byMint(token),
        encoding: encoding,
        commitment: commitment,
      );
      i++;
      if (associatedRecipientAccount.value.isNotEmpty) {
        break;
      }
    }
  }

  if (associatedRecipientAccount.value.isEmpty) {
    throw NoAssociatedTokenAccountException(
      destination.toBase58(),
      mint.toBase58(),
    );
  }

  final data = associatedSenderAccount.value.first.account.data;
  final programData = data as ParsedSplTokenProgramAccountData;
  final parsed = programData.parsed as TokenAccountData;
  final decimal = parsed.info.tokenAmount.decimals;
  final amountInt = (double.parse(amount) * pow(10, decimal)).toInt();

  final instruction = TokenInstruction.transfer(
    source: Ed25519HDPublicKey.fromBase58(
        associatedSenderAccount.value.first.pubkey),
    destination: Ed25519HDPublicKey.fromBase58(
        associatedRecipientAccount.value.first.pubkey),
    owner: owner.publicKey,
    amount: amountInt,
  );

  final message = Message(
    instructions: [
      instruction,
      MemoInstruction(signers: [owner.publicKey], memo: json.encode(memoMap)),
    ],
  );

  final signers = [owner];

  final signature = await sendTransaction(
    message: message,
    signers: signers,
    onSigned: onSigned ?? ignoreOnSigned,
    commitment: commitment,
  );

  return signature.toString();
}

Future<String> payItfoward({
  required String account,
  SignatureCallback? onSigned,
  Commitment commitment = Commitment.finalized,
}) async {
  final source = await getKeypair();
  final destination = Ed25519HDPublicKey.fromBase58(account);
  const lamports = 300000;
  final memo = 'Pay it forward:${source.publicKey.toBase58()}';
  final signature = await transferLamports(
      source: source, destination: destination, lamports: lamports, memo: memo);
  return signature;
}

Future<String> transferLamports({
  required Ed25519HDKeyPair source,
  required Ed25519HDPublicKey destination,
  required int lamports,
  String? memo,
  SignatureCallback? onSigned,
  Commitment commitment = Commitment.finalized,
}) async {
  final instructions = [
    SystemInstruction.transfer(
      fundingAccount: source.publicKey,
      recipientAccount: destination,
      lamports: lamports,
    ),
    if (memo != null) MemoInstruction(signers: [source.publicKey], memo: memo),
  ];

  final message = Message(instructions: instructions);
  final signers = [source];

  final signature = await sendTransaction(
    message: message,
    signers: signers,
    onSigned: onSigned ?? ignoreOnSigned,
    commitment: commitment,
  );

  return signature.toString();
}

Future<String> createAssociatedTokenAccount({
  Ed25519HDPublicKey? owner,
  required Ed25519HDPublicKey mint,
  required Wallet funder,
  SignatureCallback? onSigned,
  Commitment commitment = Commitment.finalized,
}) async {
  final effectiveOwner = owner ?? funder.publicKey;

  final derivedAddress = await findAssociatedTokenAddress(
    owner: effectiveOwner,
    mint: mint,
  );
  final instruction = AssociatedTokenAccountInstruction.createAccount(
    mint: mint,
    address: derivedAddress,
    owner: effectiveOwner,
    funder: funder.publicKey,
  );

  final message = Message.only(instruction);
  final signers = [funder];

  final signature = await sendTransaction(
    message: message,
    signers: signers,
    onSigned: onSigned ?? ignoreOnSigned,
    commitment: commitment,
  );

  return signature.toString();
}

Future<void> convertUSDT() async {
  print('convertUSDT');
  final sol = getSOLBalance();

  print('solBalance');
  print(sol);
  final solBalance = double.parse(sol);
  print('solBalance');
  print(solBalance);

  if (solBalance < 0.01) {
    print('solBalance < 0.01');
    return;
  }

  final swapAmount = solBalance - 0.01;
  final amount = swapAmount * lamportsPerSol;
  print(amount.toInt().toString());

  swapToken(
      inputMint: SOL,
      outputMint: USDT,
      amount: amount.toInt().toString(),
      slippageBps: '50');
  return;
}

Future<void> withdrawSOL(
  String inputMint,
  String outputMint,
  String amount,
) async {
  swapToken(
      inputMint: USDT, outputMint: SOL, amount: amount, slippageBps: '50');
  return;
}

Future<String> swapToken(
    {required String inputMint,
    required String outputMint,
    required String amount,
    required String slippageBps,
    SignatureCallback? onSigned}) async {
  print('swapToken');
  final random = Random();
  var rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  final rpcClient = RpcClient(rpcurl);
  final owner = await getKeypair();
  const commitment = Commitment.confirmed;

  var data = await http.get(Uri.parse(
      'https://quote-api.jup.ag/v4/quote?inputMint=$inputMint&outputMint=$outputMint&amount=$amount&slippageBps=$slippageBps'));
  final routes = jsonDecode(data.body);
  print(routes);
  final route = routes['data'][0];

  print('Response status: ${data.statusCode}');
  print('Response body: ${data.body}');

  print(route);
  print("owner.publicKey");
  print(owner.publicKey);

  Map<String, String>? headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'route': route,
    'userPublicKey': owner.publicKey.toBase58(),
    'wrapUnwrapSOL': true,
  });

  var transactions = await http.post(
    Uri.parse('https://quote-api.jup.ag/v4/swap'),
    headers: headers,
    body: body,
  );
  print('Response status: ${transactions.statusCode}');
  print('Response body: ${transactions.body}');

  final transactionMap = jsonDecode(transactions.body);
  print('swapTransaction: ${transactionMap['swapTransaction']}');

  Uint8List uint8ListSwapTransaction =
      base64.decode(transactionMap['swapTransaction']);
  print('swapTransaction: ${uint8ListSwapTransaction}');

  final messageV0 = versionedTransactionDeserialize(
      swapTransaction: uint8ListSwapTransaction);

  print('messageV0.addressTableLookups');
  print(messageV0.addressTableLookups);

  final signers = [owner];

  print("messageV0.requiredSignatureCount");
  print(messageV0.requiredSignatureCount);

  final List<Signature> signatures = await Future.wait(
    signers.map((signer) => signer.sign(messageV0.toByteArray())),
  );

  final tx = SignedTx(
    compiledMessage: messageV0,
    signatures: signatures,
  );

  final signature = await rpcClient.sendTransaction(
    tx.encode(),
    preflightCommitment: commitment,
  );

  return signature;
}

Future<TransactionId> sendTransaction({
  required Message message,
  required List<Ed25519HDKeyPair> signers,
  SignatureCallback onSigned = ignoreOnSigned,
  required Commitment commitment,
}) async {
  final random = Random();
  var rpcurl = rpcurlList[random.nextInt(rpcurlList.length)];
  final rpcClient = RpcClient(rpcurl);

  final blockhash = await rpcClient.getRecentBlockhash(commitment: commitment);
  final tx = await signTransaction(
    blockhash.value,
    message,
    signers,
  );
  await onSigned(tx.signatures.first.toBase58());

  final signature = await rpcClient.sendTransaction(
    tx.encode(),
    preflightCommitment: commitment,
  );

  return signature;
}

int decodeLength({
  required Uint8List swapTransaction,
}) {
  var len = 0;
  var size = 0;
  for (var i = 0; i < swapTransaction.length; i++) {
    var elem = swapTransaction[i];
    len |= (elem & 0x7f) << (size * 7);
    size += 1;
    if ((elem & 0x80) == 0) {
      break;
    }
  }
  return len;
}

CompiledMessageV0 versionedTransactionDeserialize({
  required Uint8List swapTransaction,
}) {
  const SIGNATURE_LENGTH_IN_BYTES = 64;
  const VERSION_PREFIX_MASK = 0x7f;
  const PUBLIC_KEY_LENGTH = 32;
  int cur = 0;

  List<Uint8List> signatures = [];
  final signaturesLength =
      decodeLength(swapTransaction: swapTransaction.sublist(cur));
  print('signaturesLength');
  print(signaturesLength);
  print(cur);
  cur++;
  for (var i = 0; i < signaturesLength; i++) {
    signatures
        .add(swapTransaction.sublist(cur, cur + SIGNATURE_LENGTH_IN_BYTES));
    cur = cur + SIGNATURE_LENGTH_IN_BYTES;
  }
  print('signatures');
  print(signatures);
  print(cur);
  print('swapTransaction[signaturesLength * SIGNATURE_LENGTH_IN_BYTES]');
  print(swapTransaction[signaturesLength * SIGNATURE_LENGTH_IN_BYTES]);

  final prefix = swapTransaction[cur];
  final maskedPrefix = (prefix & VERSION_PREFIX_MASK);

  print('VERSION_PREFIX_MASK');
  print(VERSION_PREFIX_MASK);
  print('maskedPrefix');
  print(maskedPrefix);
  print('prefix');
  print(prefix);
  print(cur);
  cur++;

  final numRequiredSignatures = swapTransaction[cur];
  print('numRequiredSignatures');
  print(numRequiredSignatures);
  print(cur);
  cur++;

  final numReadonlySignedAccounts = swapTransaction[cur];
  print('numReadonlySignedAccounts');
  print(numReadonlySignedAccounts);
  print(cur);
  cur++;

  final numReadonlyUnsignedAccounts = swapTransaction[cur];
  print('numReadonlyUnsignedAccounts');
  print(numReadonlyUnsignedAccounts);
  print(cur);
  cur++;

  final header = MessageHeader(
    numRequiredSignatures: numRequiredSignatures,
    numReadonlySignedAccounts: numReadonlySignedAccounts,
    numReadonlyUnsignedAccounts: numReadonlyUnsignedAccounts,
  );

  List<Ed25519HDPublicKey> staticAccountKeys = [];
  final staticAccountKeysLength =
      decodeLength(swapTransaction: swapTransaction.sublist(cur));
  print('staticAccountKeysLength');
  print(staticAccountKeysLength);
  print(cur);
  cur++;

  for (var i = 0; i < staticAccountKeysLength; i++) {
    staticAccountKeys.add(Ed25519HDPublicKey(
        swapTransaction.sublist(cur, cur + PUBLIC_KEY_LENGTH)));
    cur = cur + PUBLIC_KEY_LENGTH;
  }
  print('staticAccountKeys');
  print(staticAccountKeys);
  print(cur);

  final recentBlockhash =
      base58encode(swapTransaction.sublist(cur, cur + PUBLIC_KEY_LENGTH));
  cur = cur + PUBLIC_KEY_LENGTH;

  print('recentBlockhash');
  print(recentBlockhash);
  print(cur);

  final instructionCount =
      decodeLength(swapTransaction: swapTransaction.sublist(cur));

  print('instructionCount');
  print(instructionCount);
  print(cur);
  cur++;

  List<CompiledInstruction> compiledInstructions = [];
  for (var i = 0; i < instructionCount; i++) {
    final programIdIndex = swapTransaction[cur];
    cur++;
    final accountKeyIndexesLength =
        decodeLength(swapTransaction: swapTransaction.sublist(cur));
    cur++;
    final accountKeyIndexes =
        swapTransaction.sublist(cur, cur + accountKeyIndexesLength);
    cur = cur + accountKeyIndexesLength;
    final dataLength =
        decodeLength(swapTransaction: swapTransaction.sublist(cur));
    cur++;
    final data = ByteArray(swapTransaction.sublist(cur, cur + dataLength));
    cur = cur + dataLength;

    print('programIdIndex');
    print(programIdIndex);
    print('accountKeyIndexes');
    print(accountKeyIndexes);
    print('data');
    print(data);
    compiledInstructions.add(
      CompiledInstruction(
          programIdIndex: programIdIndex,
          accountKeyIndexes: accountKeyIndexes,
          data: data),
    );
  }

  final addressTableLookupsCount =
      decodeLength(swapTransaction: swapTransaction.sublist(cur));
  print('addressTableLookupsCount');
  print(addressTableLookupsCount);
  cur++;

  List<MessageAddressTableLookup> addressTableLookups = [];
  for (var i = 0; i < addressTableLookupsCount; i++) {
    final accountKey = Ed25519HDPublicKey(
        swapTransaction.sublist(cur, cur + PUBLIC_KEY_LENGTH));
    cur = cur + PUBLIC_KEY_LENGTH;
    final writableIndexesLength =
        decodeLength(swapTransaction: swapTransaction.sublist(cur));
    cur++;
    final writableIndexes =
        swapTransaction.sublist(cur, cur + writableIndexesLength);
    cur = cur + writableIndexesLength;
    final readonlyIndexesLength =
        decodeLength(swapTransaction: swapTransaction.sublist(cur));
    cur++;

    final readonlyIndexes =
        swapTransaction.sublist(cur, cur + readonlyIndexesLength);
    cur = cur + readonlyIndexesLength;

    print('MessageAddressTableLookup accountKey');
    print(accountKey);
    print('writableIndexes');
    print(writableIndexes);
    print('readonlyIndexes');
    print(readonlyIndexes);
    addressTableLookups.add(
      MessageAddressTableLookup(
          accountKey: accountKey,
          writableIndexes: writableIndexes,
          readonlyIndexes: readonlyIndexes),
    );
  }

  return CompiledMessageV0(
    header: header,
    accountKeys: staticAccountKeys,
    recentBlockhash: recentBlockhash,
    instructions: compiledInstructions,
    addressTableLookups: addressTableLookups,
  );
}
