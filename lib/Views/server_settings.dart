import 'package:flutter/material.dart';

/// 관리자가 포털에서 서버 상태를 더 세밀하게 조정하고 싶을 때 사용하는 페이지이다.
///
/// 관리자 계정으로 로그인 하면 해당 페이지에 접근이 가능하다.
/// 이 페이지는 필요 여부가 명확하지 않기에 사용 대기 상태이다.
class ServerSettingsPage extends StatelessWidget {
  const ServerSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서버 상태 변경(고급)')),
      body: const Center(
        child: Text('사용자 관리 페이지 입니다.'),
      ),
    );
  }
}
