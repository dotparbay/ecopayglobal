import 'package:objectbox/objectbox.dart';
import 'package:solana/solana.dart';

@Entity()
class TransactionInfo {
  TransactionInfo(
      {this.id = 0,
      this.signature,
      this.slot,
      this.err,
      this.memo,
      this.blockTime,
      this.confirmationStatus,
      this.transactionDetails});

  int id;

  @Unique()
  String? signature;

  int? slot;
  String? err;
  String? memo;
  int? blockTime;

  @Transient()
  Commitment? confirmationStatus;

  String? transactionDetails;

  int? get dbConfirmationStatus {
    _ensureStableEnumValues();
    return confirmationStatus?.index;
  }

  set dbConfirmationStatus(int? value) {
    _ensureStableEnumValues();
    if (value == null) {
      confirmationStatus = null;
    } else {
      confirmationStatus =
          Commitment.values[value]; // throws a RangeError if not found
    }
  }

  void _ensureStableEnumValues() {
    assert(Commitment.processed.index == 0);
    assert(Commitment.confirmed.index == 1);
    assert(Commitment.finalized.index == 2);
  }
}

@Entity()
class TokenAccount {
  TokenAccount({
    this.id = 0,
    this.pubkey,
    this.mint,
  });

  int id;

  @Unique()
  String? pubkey;

  String? mint;
}

@Entity()
class TokenAccountBalance {
  TokenAccountBalance({
    this.id = 0,
    this.pubkey,
    this.amount,
    this.decimals,
    this.uiAmountString,
  });

  int id;

  @Unique()
  String? pubkey;

  String? amount;
  int? decimals;
  String? uiAmountString;
}

@Entity()
class Whitelist {
  Whitelist({
    this.id = 0,
    this.pubkey,
  });

  int id;

  @Unique()
  String? pubkey;
}

@Entity()
class Item {
  Item(
      {this.id = 0,
      this.name,
      this.price,
      this.category,
      this.memo,
      this.url,
      this.image,
      this.deleteAt});

  int id;

  String? name;
  String? price;
  String? category;
  String? memo;
  String? url;
  String? image;
  int? deleteAt;
}

@Entity()
class CartItem {
  CartItem({
    this.id = 0,
    this.itemID,
  });

  int id;

  int? itemID;
}
