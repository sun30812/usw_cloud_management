/// 현재 서버 상태를 나타내는 열거형
///
/// 현재 서버의 상태를 크게 3가지로 분류한 것이다.
///
/// ## 종류별 설명
/// - [normal]: 서버가 정상적으로 동작함
/// - [fixing]: 서버가 현재 유지보수 상태임
/// - [error]: 서버에 오류가 발생함
/// - [stopped]: 서버가 중단된 상태
enum ServerStatus { normal, fixing, error, stopped }

/// 현재 사용자의 상태를 나타내는 열거형
///
/// 현재 서버의 상태를 크게 3가지로 분류한 것이다.
///
/// ## 종류별 설명
/// - [normal]: 정상 사용자
/// - [unregistered]: 아직 계정이 심사중인 사용자
/// - [needReset]: 암호 재설정을 요청한 사용자
/// - [banned]: 포털 사용이 차단된 사용자
enum UserType {
  normal,
  unregistered,
  needReset,
  banned,
}

/// 사용자 관리 페이지에서 표시할 사용자 분류에 사용되는 열거형
///
/// 사용자 관리 페이지와 같이 표시할 사용자에 대한 분류가 필요할 때 사용된다.
///
/// ## 종류별 설명
/// - [all]: 등록되어있는 모든 사용자
/// - [locked]: 계정이 잠긴 사용자
/// - [signup]: 서버에 계정 등록을 요청한 사용자
/// - [requiredReset]: 비밀번호를 잃어서 초기화를 요청한 사용자
enum UserQueryType {
  all,
  locked,
  signup,
  requiredReset,
}

/// [UserQueryType]에서 일부 기능을 추가하기위해 만든 확장
///
///
extension UserQueryTypeExtension on UserQueryType {
  /// [UserQueryType]을 [DropdownMenuItem]에 사용할 수 있도록 제공하는 문자열 값
  ///
  /// [DropdownMenuItem]을 사용할 때 사용자가 식별 가능한 문자열로 볼 수 있도록 해준다.
  ///
  /// ## 예제
  ///
  /// [stringValue]를 이용하여 사용자 퀴리 드롭다운 메뉴 항목을 만드는 예제
  ///
  /// ```dart
  /// List<DropdownMenuItem> userQueryTypeMenuItems = UserQueryType.values.map((value)
  ///   => DropdownMenuItem(value: value,child: Text(value.stringValue),)).toList();
  /// ```
  ///
  String get stringValue {
    switch (this) {
      case UserQueryType.all:
        return '등록된 모든 사용자';
      case UserQueryType.locked:
        return '잠긴 사용자';
      case UserQueryType.signup:
        return '등록 요청한 사용자';
      case UserQueryType.requiredReset:
        return '비밀번호 초기화를 요청한 사용자';
    }
  }

  /// Firebase에 사용할 수 있도록 열거형을 변환해주는 메서드이다.
  String get firebaseStorageStatus {
    switch (this) {
      case UserQueryType.all:
        return 'normal';
      case UserQueryType.locked:
        return 'normal';
      case UserQueryType.signup:
        return 'unregistered';
      case UserQueryType.requiredReset:
        return 'needReset';
    }
  }
}

/// 요청 관리 페이지에서 표시할 요청 분류에 사용되는 열거형
///
/// 사용자 관리 페이지와 같이 표시할 사용자에 대한 분류가 필요할 때 사용된다.
///
/// ## 종류별 설명
/// - [all]: 모든 요청
/// - [installation]: 패키지 설치 요청
/// - [restore]: 파일 및 시스템 복원 요청
/// - [extra]: 기타 요청
enum RequestQueryType {
  all,
  installation,
  restore,
  extra,
}

extension RequestQueryTypeExtension on RequestQueryType {
  /// [RequestQueryType]을 [DropdownMenuItem]에 사용할 수 있도록 제공하는 문자열 값
  ///
  /// [DropdownMenuItem]을 사용할 때 사용자가 식별 가능한 문자열로 볼 수 있도록 해준다.
  ///
  /// ## 예제
  ///
  /// [stringValue]를 이용하여 요청 퀴리 드롭다운 메뉴 항목을 만드는 예제
  ///
  /// ```dart
  /// List<DropdownMenuItem> requestQueryTypeMenuItems = RequestQueryType.values.map((value)
  ///   => DropdownMenuItem(value: value,child: Text(value.stringValue))).toList();
  /// ```
  ///
  String get stringValue {
    switch (this) {
      case RequestQueryType.all:
        return '모든 요청';
      case RequestQueryType.installation:
        return '설치 요청';
      case RequestQueryType.restore:
        return '복원 요청';
      case RequestQueryType.extra:
        return '기타 요청';
    }
  }
}
