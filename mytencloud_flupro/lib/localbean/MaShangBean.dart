class SomeRootEntityDataDataList {

  String id="";
  String title="";
  String auth="";
  String developTime="";
  String hits="";
  String favors="";
  String keshi="";
  int isFavor=0;
  String commentNums="";

  SomeRootEntityDataDataList({
    required this.id,
    required this.title,
    required this.auth,
    required this.developTime,
    required this.hits,
    required this.favors,
    required this.keshi,
    required this.isFavor,
    required this.commentNums,
  });
  SomeRootEntityDataDataList.fromJson(Map<String, dynamic> json) {
    id = json['id']!.toString();
    title = json['title']!.toString();
    auth = json['auth']!.toString();
    developTime = json['develop_time']!.toString();
    hits = json['hits']!.toString();
    favors = json['favors']!.toString();
    keshi = json['keshi']!.toString();
    isFavor = json['is_favor']?.toInt();
    commentNums = json['comment_nums']!.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['auth'] = auth;
    data['develop_time'] = developTime;
    data['hits'] = hits;
    data['favors'] = favors;
    data['keshi'] = keshi;
    data['is_favor'] = isFavor;
    data['comment_nums'] = commentNums;
    return data;
  }
}

class SomeRootEntityDataData {
/*
{
  "total": "11",
  "list": [
    {
      "id": "11",
      "title": "成人生命8要素评分（LE8）",
      "auth": "1",
      "develop_time": "",
      "hits": "95",
      "favors": "1",
      "keshi": null,
      "is_favor": 0,
      "comment_nums": "4"
    }
  ]
}
*/

  String total="";
  List<SomeRootEntityDataDataList> list= [];

  SomeRootEntityDataData({
    required this.total,
    required this.list,
  });
  SomeRootEntityDataData.fromJson(Map<String, dynamic> json) {
    total = json['total']!.toString();
    if (json['list'] != null) {
      final v = json['list'];
      final arr0 = <SomeRootEntityDataDataList>[];
      v.forEach((v) {
        arr0.add(SomeRootEntityDataDataList.fromJson(v));
      });
      list = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['total'] = total;
    if (list != null) {
      final v = list;
      final arr0 = [];
      v.forEach((v) {
        arr0.add(v.toJson());
      });
      data['list'] = arr0;
    }
    return data;
  }
}

class SomeRootEntityData {
/*
{
  "status": "1",
  "errorMessage": "",
  "data": {
    "total": "11",
    "list": [
      {
        "id": "11",
        "title": "成人生命8要素评分（LE8）",
        "auth": "1",
        "develop_time": "",
        "hits": "95",
        "favors": "1",
        "keshi": null,
        "is_favor": 0,
        "comment_nums": "4"
      }
    ]
  }
}
*/

  String status="";
  String errorMessage="";
  SomeRootEntityDataData data=SomeRootEntityDataData(total: '', list: []);

  SomeRootEntityData({
    required this.status,
    required this.errorMessage,
    required this.data,
  });
  SomeRootEntityData.fromJson(Map<String, dynamic> json) {
    status = json['status']!.toString();
    errorMessage = json['errorMessage']!.toString();
    data = ((json['data'] != null)
        ? SomeRootEntityDataData.fromJson(json['data'])
        : null)!;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['errorMessage'] = errorMessage;
    if (data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class SomeRootEntity {
/*
{
  "code": "200",
  "message": "success",
  "data": {
    "status": "1",
    "errorMessage": "",
    "data": {
      "total": "11",
      "list": [
        {
          "id": "11",
          "title": "成人生命8要素评分（LE8）",
          "auth": "1",
          "develop_time": "",
          "hits": "95",
          "favors": "1",
          "keshi": null,
          "is_favor": 0,
          "comment_nums": "4"
        }
      ]
    }
  }
}
*/

  String code="";
  String message="";
  SomeRootEntityData data=SomeRootEntityData(status: '', errorMessage: '', data: SomeRootEntityDataData(total: '', list: []));

  SomeRootEntity({
    required this.code,
    required this.message,
    required this.data,
  });
  SomeRootEntity.fromJson(Map<String, dynamic> json) {
    code = json['code']!.toString();
    message = json['message']!.toString();
    data = ((json['data'] != null)
        ? SomeRootEntityData.fromJson(json['data'])
        : null)!;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    if (data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}
