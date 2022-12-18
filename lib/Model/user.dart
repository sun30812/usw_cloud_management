import 'package:usw_cloud_management/Model/types.dart';

/// 사용자 객체에 대한 클래스이다.
///
/// 사용자의 정보를 담고있는 클래스로 사용자에 대한 정보를 다룰 때 활용할 수 있다.
class User {
  /// 사용자 계정의 잠금 상태 여부
  bool isLocked;

  /// 사용자 계정의 상태
  UserType status;

  /// 사용자의 학번
  int studentId;

  /// 사용자의 ID
  String id;

  /// 사용자의 이름
  String username;

  /// 사용자 객체를 생성한다.
  ///
  /// 사용자의 ID를 [id]에 기입하고, 이름은 [username]에 기입하면 된다.
  /// 학번은 [studentId]에, 계정의 상태나 잠긴 계정 여부는 [status]와 [isLocked]를
  /// 통해 지정이 가능하다. 모든 매개변수에 값이 필요하다.
  User({
    required this.isLocked,
    required this.status,
    required this.studentId,
    required this.id,
    required this.username,
  });

  /// FirebaseDatabase를 통해서 사용자 정보를 가져오는 경우 사용하는 메서드
  ///
  /// Google의 *Firebase*에서 데이터를 가져오는 경우 가져온 데이터를 [User]에
  /// 맞게 변환시켜준다. 가져온 데이터는 [Map]형태로 존재하는데 `key` 값을
  /// [id]에 넘기고, `value`값을 [json]에 넘기면 된다.
  factory User.fromFirebaseDatabase(dynamic id, dynamic json) {
    return User(
        isLocked: json['isLocked'] as bool,
        status: UserType.values.byName(json['status']),
        id: id,
        studentId: json['studentId'] as int,
        username: json['username'].toString());
  }

  /// 빈(`null`) 사용자 객체를 반환하는 메서드
  ///
  /// 테스트나 접근 제한 목적으로 `null`값을 지닌 사용자를 반환하는 메서드이다.
  /// 기본적으로 계정은 잠금상태이며, 학번은 -1로 이름이나 id는 [UserType.banned]로
  /// 지정된다.
  factory User.unknown() {
    return User(
        isLocked: true,
        status: UserType.banned,
        id: 'null',
        studentId: -1,
        username: 'null');
  }

  /// [User]인스턴스를 JSON으로 직렬화 시킬 때 사용되는 메서드이다.
  Map<String, dynamic> toJson() => {
        'isLocked': isLocked,
        'status': status.name,
        'studentId': studentId,
        'id': id,
        'username': username
      };

  /// JSON에서 [User]로 역직렬화할 때 사용되는 메서드이다.
  factory User.fromJson(Map<String, dynamic> json) => User(
      isLocked: json['isLocked'],
      status: UserType.values.byName(json['status']),
      studentId: json['studentId'],
      id: json['id'],
      username: json['username']);
}
