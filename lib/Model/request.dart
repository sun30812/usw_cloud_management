import 'package:usw_cloud_management/Model/types.dart';

/// 요청 페이지에서 요청 정보를 담기위한 객체로 사용되는 클래스이다.
class Request {
  /// 요청 항목당 주어지는 고유한 ID
  String requestId;

  /// 요청한 사용자의 ID
  String id;

  /// 요청 내용
  String content;

  /// 요청 종류
  RequestQueryType kind;
  Request({
    required this.requestId,
    required this.id,
    required this.content,
    required this.kind,
  });

  /// Firebase에서 요청 정보를 가져올 때 사용하는 메서드. Firebase에서 받은 내용을 통해 [Request]인스턴스로 반환한다.
  factory Request.fromFirebaseDatabase(dynamic id, dynamic json) {
    return Request(
        requestId: id.toString(),
        id: json['id'].toString(),
        content: json['content'].toString(),
        kind: RequestQueryType.values.byName(json['kind']));
  }
}
