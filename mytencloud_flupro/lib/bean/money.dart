const String tableNotes = 'money';

class MoneyFields {
  static final List<String> values = [
    /// Add all fields
    id, type, money, datetime, useway
  ];

  static const String id = '_id';
  static const String type = 'type'; //类型0:支出1收入
  static const String money = 'money'; //金额
  static const String datetime = 'datetime'; //日期
  static const String useway = 'useway'; //用途

}

class Money {
  int id=0;
  String type="";
  String money="";
  DateTime datetime=DateTime.now();
  String useway="";

  Money({required this.id, required this.type, required this.money,required this.datetime,required this.useway});

  Money copy({
    int? id,
    String? type,
    String? money,
    String? useway,
    DateTime? datetime,
  }) =>
      Money(
        id: id ?? this.id,
        type: type ?? this.type,
        money: money ?? this.money,
        useway: useway ?? this.useway,
        datetime: datetime ?? this.datetime,
      );

  static Money fromJson(Map<String, Object?> json) => Money(
        id: json[MoneyFields.id] as int,
        type: json[MoneyFields.type] as String,
        money: json[MoneyFields.money] as String,
        useway: json[MoneyFields.useway] as String,
        datetime: DateTime.parse(json[MoneyFields.datetime] as String),
      );

  Map<String, Object> toJson() => {
        MoneyFields.id: id!,
        MoneyFields.type: type!,
        MoneyFields.money: money!,
        MoneyFields.useway: useway!,
        MoneyFields.datetime: datetime!.toIso8601String(),
      };
}
