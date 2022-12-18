import 'package:usw_cloud_management/Model/types.dart';

/// 서버 상태에 대한 정보를 가지는 클래스이다.
/// 대시보드의 상단에 [status]를 토대로 서버의 정상 작동 여부를 확인한다.
/// [address]는 서버의 주소를 나타내는데 사용되고, [port]는 포트번호를 나타내는데 사용된다.
class ServerInfo {
  /// 서버의 주소
  final String address;

  /// 서버의 포트번호
  final int port;

  /// 서버의 상태. 서버의 상태를 [ServerStatus]를 통해 나타낸다.
  final ServerStatus status;

  const ServerInfo(
      {required this.address, required this.port, required this.status});

  /// Firebase에서 서버 정보를 가져올 때 사용되는 메서드이다.
  factory ServerInfo.fromFirebase(Map<String, dynamic> json) => ServerInfo(
      address: json['address'],
      port: json['port'],
      status: ServerStatus.values.byName(json['status']));
}
