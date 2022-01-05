// @dart=2.12


import 'package:decimal/decimal.dart';

class ValueHistoryFields {
  static final List<String> values = [
    id,tokenName,value,dateTime
  ];

  //para sql, sempre coloque _ antes do id
  static final String id = '_id';
  static final String tokenName = 'tokenName';
  static final String value = 'value';
  static final String dateTime = 'dateTime';

  static final String table = 'valueHistory';
}

class TokenHistory {
  final int? id;
  final String tokenName;
  final Decimal value;
  final int dateTime;

  const TokenHistory({
    this.id,
    required this.tokenName,
    required this.value,
    required this.dateTime,
  });

  TokenHistory copy({
    int? id,
    String? tokenName,
    Decimal? value,
    int? dateTime,
  }) {
    return TokenHistory(
      id: id ?? this.id,
      tokenName : tokenName ?? this.tokenName,
      value : value ?? this.value,
      dateTime : dateTime ?? this.dateTime,
    );
  }

  static TokenHistory fromMap(Map<String, dynamic> map) {
    return TokenHistory(
      id: map[ValueHistoryFields.id] as int?,
      tokenName: map[ValueHistoryFields.tokenName] as String,
      value: Decimal.parse(map[ValueHistoryFields.value]),
      dateTime: map[ValueHistoryFields.dateTime] as int,
    );
  }

  //Converter TokenValue em Mapa
  Map<String, dynamic> toMap() {
    return {
      ValueHistoryFields.id : id,
      ValueHistoryFields.tokenName : tokenName,
      ValueHistoryFields.value : value.toString(),
      ValueHistoryFields.dateTime : dateTime,
    };
  }

  @override
  String toString() {
    return 'TokenValue{id: $id, tokenName: $tokenName, value: $value, dateTime: $dateTime}';
  }
}