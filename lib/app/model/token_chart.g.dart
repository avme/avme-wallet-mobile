// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_chart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenChartAdapter extends TypeAdapter<TokenChart> {
  @override
  final int typeId = 0;

  @override
  TokenChart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TokenChart()..tokenList = (fields[0] as Map)?.cast<int, String>();
  }

  @override
  void write(BinaryWriter writer, TokenChart obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.tokenList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenChartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
