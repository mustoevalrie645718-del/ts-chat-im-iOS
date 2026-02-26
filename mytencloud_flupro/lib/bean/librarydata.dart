const String tableLibrarys = 'library';

class LibraryFields {
  static final List<String> values = [
    /// Add all fields
    id, color, isbold, datetime, facemotion, title, maincontain, createtime,
    moneytype, useway, amount, duration
  ];

  static const String id = '_id';
  static const String color = 'color'; //字体颜色
  static const String isbold = 'isbold'; //是否粗体 1粗0细
  static const String datetime = 'datetime'; //日期
  static const String facemotion = 'facemotion'; //表情
  static const String title = 'title'; //标题
  static const String maincontain = 'maincontain'; //正文
  static const String moneytype = 'moneytype'; //类型
  static const String useway = 'useway'; //用途
  static const String amount = 'amount'; //金额
  static const String duration = 'duration'; //期限
  static const String createtime = "createtime"; //创建时间

}

class Library {
  int id=0;
  String color="";
  String isbold="";
  DateTime datetime=DateTime.now();
  DateTime createtime=DateTime.now();
  String facemotion="";
  String title="";
  String maincontain="";
  String moneytype;
  String useway="";
  String amount="";
  String duration="";

  Library(
      {required this.id,
      required this.color,
        required this.isbold,
        required this.datetime,
        required this.facemotion,
        required  this.title,
        required  this.maincontain,
        required this.moneytype,
        required  this.useway,
        required  this.amount,
        required  this.duration,
        required   this.createtime});

  Library copy({
    int? id,
    String? color,
    String? isbold,
    DateTime? datetime,
    String? facemotion,
    String? title,
    String? moneytype,
    String? amount,
    String? duration,
    String? useway,
    String? maincontain,
    DateTime? createtime,
  }) =>
      Library(
        id: id ?? this.id,
        color: color ?? this.color,
        isbold: isbold ?? this.isbold,
        datetime: datetime ?? this.datetime,
        facemotion: facemotion ?? this.facemotion,
        moneytype: moneytype ?? this.moneytype,
        duration: duration ?? this.duration,
        useway: useway ?? this.useway,
        amount: amount ?? this.amount,
        title: title ?? this.title,
        maincontain: maincontain ?? this.maincontain,
        createtime: createtime ?? this.createtime,
      );

  static Library fromJson(Map<String, Object?> json) => Library(
        id: json[LibraryFields.id] as int,
        color: json[LibraryFields.color] as String,
        isbold: json[LibraryFields.isbold] as String,
        facemotion: json[LibraryFields.facemotion] as String,
        amount: json[LibraryFields.amount] as String,
        useway: json[LibraryFields.useway] as String,
        moneytype: json[LibraryFields.moneytype] as String,
        duration: json[LibraryFields.duration] as String,
        datetime: DateTime.parse(json[LibraryFields.datetime] as String),
        title: json[LibraryFields.title] as String,
        maincontain: json[LibraryFields.maincontain] as String,
        createtime: DateTime.parse(json[LibraryFields.createtime] as String),
      );

  Map<String, Object> toJson() => {
        LibraryFields.id: id!,
        LibraryFields.color: color!,
        LibraryFields.isbold: isbold!,
        LibraryFields.facemotion: facemotion!,
        LibraryFields.title: title!,
        LibraryFields.amount: amount!,
        LibraryFields.moneytype: moneytype!,
        LibraryFields.useway: useway!,
        LibraryFields.duration: duration!,
        LibraryFields.maincontain: maincontain!,
        LibraryFields.datetime: datetime!.toIso8601String(),
        LibraryFields.createtime: createtime!.toIso8601String(),
      };
}
