// @dart=2.12

class RecentlySentFields {
  static final List<String> values = [
    id,name,contactId
  ];

  //para sql, sempre coloque _ antes do id
  static const String id = '_id';
  static const String name = 'name';
  static const String contactId = 'contactId';

  static const String table = 'recently_sent';
}

class RecentlySent {
  final int? id;
  final String name;
  final String contactId;

  const RecentlySent({
    this.id,
    required this.name,
    required this.contactId,
  });

  RecentlySent copy({
    int? id,
    String? name,
    String? contactId,
  }) {
    return RecentlySent(
      id: id ?? this.id,
      name : name ?? this.name,
      contactId : contactId ?? this.contactId,
    );
  }

  static RecentlySent fromMap(Map<String, dynamic> map) {
    return RecentlySent(
      id: map[RecentlySentFields.id] as int?,
      name: map[RecentlySentFields.name] as String,
      contactId: map[RecentlySentFields.contactId] as String,
    );
  }

  //Converter TokenValue em Mapa
  Map<String, dynamic> toMap() {
    return {
      RecentlySentFields.id : id,
      RecentlySentFields.name : name,
      RecentlySentFields.contactId : contactId,
    };
  }

  @override
  String toString() {
    return 'RecentlySent{id: $id, name: $name, contactId: $contactId}';
  }
}