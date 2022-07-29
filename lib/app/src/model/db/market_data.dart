import 'package:decimal/decimal.dart';

class MarketDataFields {
  static final List<String> values = [
    id,tokenName,value,dateTime
  ];
  static final String id = 'id';
  static final String tokenName = 'tokenName';
  static final String value = 'value';
  static final String dateTime = 'dateTime';
  static final String table = 'tbMarketData';
}

class MarketData {
  final int? id;
  final String tokenName;
  final Decimal value;
  final int dateTime;

  const MarketData({
    this.id,
    required this.tokenName,
    required this.value,
    required this.dateTime,
  });

  MarketData copy({
    int? id,
    String? tokenName,
    Decimal? value,
    int? dateTime,
  }) {
    return MarketData(
      id: id ?? this.id,
      tokenName : tokenName ?? this.tokenName,
      value : value ?? this.value,
      dateTime : dateTime ?? this.dateTime,
    );
  }

  static MarketData fromMap(Map<String, dynamic> map) {
    return MarketData(
      id: map[MarketDataFields.id] as int?,
      tokenName: map[MarketDataFields.tokenName] as String,
      value: Decimal.parse(map[MarketDataFields.value]),
      dateTime: map[MarketDataFields.dateTime] as int,
    );
  }

  //Converter TokenValue em Mapa
  Map<String, dynamic> toMap() {
    return {
      MarketDataFields.id : id,
      MarketDataFields.tokenName : tokenName,
      MarketDataFields.value : value.toString(),
      MarketDataFields.dateTime : dateTime,
    };
  }

  @override
  String toString() {
    return 'TokenValue{id: $id, tokenName: $tokenName, value: $value, dateTime: $dateTime}';
  }
}