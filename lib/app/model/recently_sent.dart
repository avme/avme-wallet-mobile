// @dart=2.12

class RecentlySentFields {
  static final List<String> values = [
    id,name,address
  ];

  //para sql, sempre coloque _ antes do id
  static const String id = '_id';
  static const String name = 'name';
  static const String address = 'address';

  static const String table = 'recently_sent';
}

class RecentlySent {
  final int? id;
  final String name;
  final String address;

  const RecentlySent({
    this.id,
    required this.name,
    required this.address,
  });

  RecentlySent copy({
    int? id,
    String? name,
    String? address,
  }) {
    return RecentlySent(
      id: id ?? this.id,
      name : name ?? this.name,
      address : address ?? this.address,
    );
  }

  static RecentlySent fromMap(Map<String, dynamic> map) {
    return RecentlySent(
      id: map[RecentlySentFields.id] as int?,
      name: map[RecentlySentFields.name] as String,
      address: map[RecentlySentFields.address] as String,
    );
  }

  //Converter TokenValue em Mapa
  Map<String, dynamic> toMap() {
    return {
      RecentlySentFields.id : id,
      RecentlySentFields.name : name,
      RecentlySentFields.address : address,
    };
  }

  @override
  String toString() {
    return 'RecentlySent{id: $id, name: $name, address: $address}';
  }
}