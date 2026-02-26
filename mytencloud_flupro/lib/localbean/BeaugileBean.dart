/// code : 1
/// msg : "数据返回成功！"
/// data : [{"imageUrl":"http://power-api.cretinzp.com:8000/girls/22/rtrquglkwmmmjqzo.jpg","imageSize":"1728x1080","imageFileLength":99989},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/132/rk1xpsqmkit8me8r.jpg","imageSize":"1920x1080","imageFileLength":114093},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/329/hhqnnsilvvlntlid.jpg","imageSize":"1920x1080","imageFileLength":145914},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/347/spreeflorq8ijmmy.jpg","imageSize":"1920x1080","imageFileLength":106016},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/356/suxqbmhfkpnsoqop.jpg","imageSize":"1728x1080","imageFileLength":265738},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/489/jqclnsklqjgrompq.jpg","imageSize":"1920x1080","imageFileLength":196138},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/716/7hcpbficsuunpsou.jpg","imageSize":"1728x1080","imageFileLength":186515},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/883/uwfgunkgqwrdrmn9.jpg","imageSize":"1920x1080","imageFileLength":112456},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/906/krlnhdjhlqcwbgot.jpg","imageSize":"1622x1080","imageFileLength":148547},{"imageUrl":"http://power-api.cretinzp.com:8000/girls/989/zljj9lg7ilkxxpok.jpg","imageSize":"1728x1080","imageFileLength":172914}]

class Beautyimgbean {
  Beautyimgbean({
      required this.code,
      required this.msg,
      required this.data,});

  Beautyimgbean.fromJson(dynamic json) {
    code = json['code'];
    msg = json['msg'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  int code=0;
  String msg="";
  List<Data> data= [];

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['msg'] = msg;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// imageUrl : "http://power-api.cretinzp.com:8000/girls/22/rtrquglkwmmmjqzo.jpg"
/// imageSize : "1728x1080"
/// imageFileLength : 99989

class Data {
  Data({
      required this.imageUrl,
      required this.imageSize,
      required this.imageFileLength,});

  Data.fromJson(dynamic json) {
    imageUrl = json['imageUrl'];
    imageSize = json['imageSize'];
    imageFileLength = json['imageFileLength'];
  }
  String imageUrl="";
  String imageSize="";
  int imageFileLength=0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['imageUrl'] = imageUrl;
    map['imageSize'] = imageSize;
    map['imageFileLength'] = imageFileLength;
    return map;
  }

}