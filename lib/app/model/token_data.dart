// @dart=2.12
final String tokenValueTable = 'tokenValueTable';

class TokenValueFields {
  static final List<String> values = [
    id,tokenName,value,dateTime
  ];

  //para sql, sempre coloque _ antes do id
  static final String id = '_id';
  static final String tokenName = 'tokenName';
  static final String value = 'value';
  static final String dateTime = 'dateTime';
}

class TokenValue {
  final int? id;
  final String tokenName;
  final double value;
  final int dateTime;

  const TokenValue({
    this.id,
    required this.tokenName,
    required this.value,
    required this.dateTime,
  });

  TokenValue copy({
    int? id,
    String? tokenName,
    double? value,
    int? dateTime,
  }) {
    return TokenValue(
      id: id ?? this.id,
      tokenName : tokenName ?? this.tokenName,
      value : value ?? this.value,
      dateTime : dateTime ?? this.dateTime,
    );
  }

  static TokenValue fromMap(Map<String, dynamic> map) {
    return TokenValue(
      id: map[TokenValueFields.id] as int?,
      tokenName: map[TokenValueFields.tokenName] as String,
      value: map[TokenValueFields.value] as double,
      dateTime: map[TokenValueFields.dateTime] as int,
    );
  }

  //Converter TokenValue em Mapa
  Map<String, dynamic> toMap() {
    return {
      TokenValueFields.id : id,
      TokenValueFields.tokenName : tokenName,
      TokenValueFields.value : value,
      TokenValueFields.dateTime : dateTime,
    };
  }

  @override
  String toString() {
    return 'TokenValue{id: $id, tokenName: $tokenName, value: $value, dateTime: $dateTime}';
  }
}