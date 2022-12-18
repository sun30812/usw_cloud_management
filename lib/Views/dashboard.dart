import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:usw_cloud_management/Model/server_info.dart';
import 'package:usw_cloud_management/Views/style.dart';
import 'package:go_router/go_router.dart';
import '../Model/types.dart';

/// 관리자로써 포털에 접근할 때 보여지는 페이지이다.
///
/// 관리자 계정으로 로그인 하면 사용자들을 관리하거나 공지사항을 작성할 수 있는 페이지로 이동한다.
/// 만일 본인이 관리자가 아닌데 이 페이지에 접속을 시도하는 경우 go_route에 의해 접근이 제한된다.
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  /// 현재 서버 상태를 나타낸다.
  ///
  /// ## 같이보기
  /// - [ServerStatus]
  ServerStatus _currentServerStatus = ServerStatus.normal;

  /// 서버 상태별로 정보를 출력하는 위젯
  ///
  /// [status]를 통해 서버 상태를 확인하여 그에 알맞은 위젯을 반환한다.
  /// 이 위젯은 대시보드 가장 위에 존재하고 사용자의 경우에는 서버 상태 확인이
  /// 가능하고, 관리자의 경우 서버 상태를 변경할 수 있다.
  ///
  /// ## 같이보기
  ///
  /// - [ServerStatus]
  Widget serverStatusInfo(ServerStatus status) {
    switch (status) {
      case ServerStatus.normal:
        return Row(
          children: const [
            Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
            ),
            Text(
              '현재 서버가 정상적으로 가동되는 중 입니다.',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        );
      case ServerStatus.fixing:
        return Row(
          children: const [
            Icon(
              Icons.warning,
              color: Colors.orangeAccent,
            ),
            Text(
              '현재 서버의 유지보수를 진행하고 있습니다.',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        );
      case ServerStatus.error:
        return Row(
          children: const [
            Icon(
              Icons.desktop_access_disabled_outlined,
              color: Colors.redAccent,
            ),
            Text(
              '현재 서버가 작동되지 않습니다.',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        );
      case ServerStatus.stopped:
        return Row(
          children: const [
            Icon(
              Icons.desktop_access_disabled_outlined,
              color: Colors.redAccent,
            ),
            Text(
              '현재 서버가 꺼져있습니다.',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        );
    }
  }

  /// 화면 크기에 맞춰 한 행에 표시할 포스트 카드의 개수를 반환하는 메서드
  ///
  /// 화면 크기 별로 알맞은 크기의 카드를 제공하기 위해 화면의 너비를 [size]로 넘겨받아서
  /// 한 행에 적합한 카드 개수를 구한다.
  int getCrossAxisCount(int size) {
    if (size < 300) {
      return 1;
    } else if (size >= 300 && size < 550) {
      return 2;
    } else if (size >= 550 && size < 900) {
      return 3;
    }
    return 4;
  }

  /// 화면 크기에 맞춰 맞는 비율을 반환하는 메서드
  ///
  /// 화면 크기 별로 알맞은 크기의 카드를 제공하기 위해 화면의 너비를 [size]로 넘겨받아서
  /// 최적의 비율을 구한다.
  double getAspectRatio(int size) {
    if (size < 300) {
      return 1 / 0.6;
    } else if (size >= 300 && size < 550) {
      return 1 / 0.8;
    } else {
      return 1 / 1.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('수원대 클라우드 포털 - 관리자'),
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseAuth.instance
                    .signOut()
                    .then((value) => context.go('/'));
              },
              icon: const Icon(Icons.power_settings_new_outlined))
        ],
      ),
      body: Column(
        children: [
          DynamicCard(
              icon: Icons.computer_outlined,
              title: '서버 접속 안내',
              content: StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance.ref('server').onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else {
                      Map<String, dynamic> data =
                          snapshot.data!.snapshot.value as Map<String, dynamic>;
                      ServerInfo serverInfo = ServerInfo.fromFirebase(data);
                      _currentServerStatus = serverInfo.status;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          serverStatusInfo(serverInfo.status),
                          Text(
                              '서버 주소: ${serverInfo.address}\n포트: ${serverInfo.port}')
                        ],
                      );
                    }
                  })),
          const NoticeCard(isAdmin: true),
          Expanded(
            child: GridView.count(
              crossAxisCount: getCrossAxisCount(
                  MediaQuery.of(context).size.width.toInt() - 300),
              childAspectRatio: getAspectRatio(
                  MediaQuery.of(context).size.width.toInt() - 300),
              children: [
                DynamicCard(
                  icon: Icons.people_outline,
                  title: '사용자관리',
                  content: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('현재 등록된 사용자'),
                        onTap: () => context.go('/dashboard/users',
                            extra: UserQueryType.all),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('계정이 잠긴 사용자'),
                        onTap: () => context.go('/dashboard/users',
                            extra: UserQueryType.locked),
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add_alt),
                        title: const Text('등록을 요청한 사용자'),
                        onTap: () => context.go('/dashboard/users',
                            extra: UserQueryType.signup),
                      ),
                      ListTile(
                        leading: const Icon(Icons.key_outlined),
                        title: const Text('비밀번호 초기화를 요청한 사용자'),
                        onTap: () => context.go('/dashboard/users',
                            extra: UserQueryType.requiredReset),
                      ),
                    ],
                  ),
                ),
                DynamicCard(
                    icon: Icons.pending_actions,
                    title: '요청 작업',
                    content: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.feed_outlined),
                          title: const Text('모든 요청'),
                          onTap: () => context.go('/dashboard/request',
                              extra: RequestQueryType.all),
                        ),
                        ListTile(
                          leading: const Icon(Icons.get_app_outlined),
                          title: const Text('설치를 요청한 패키지'),
                          onTap: () => context.go('/dashboard/request',
                              extra: RequestQueryType.installation),
                        ),
                        ListTile(
                          leading: const Icon(Icons.restore),
                          title: const Text('파일 복원을 요청한 사용자'),
                          onTap: () => context.go('/dashboard/request',
                              extra: RequestQueryType.restore),
                        ),
                        ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: const Text('기타 사항을 요구한 사용자'),
                          onTap: () => context.go('/dashboard/request',
                              extra: RequestQueryType.extra),
                        ),
                      ],
                    )),
                DynamicCard(
                    icon: Icons.bar_chart,
                    title: '서버 상태 변경',
                    content: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('서버 사용자들에게 보여지는 접속 안내 내용을 변경합니다.'),
                        RadioListTile(
                            title: const Text('정상'),
                            value: ServerStatus.normal,
                            groupValue: _currentServerStatus,
                            onChanged: (newValue) async {
                              await FirebaseDatabase.instance
                                  .ref('server')
                                  .update({'status': newValue!.name});
                              setState(() {
                                _currentServerStatus = newValue;
                              });
                            }),
                        RadioListTile(
                            title: const Text('유지보수'),
                            value: ServerStatus.fixing,
                            groupValue: _currentServerStatus,
                            onChanged: (newValue) async {
                              await FirebaseDatabase.instance
                                  .ref('server')
                                  .update({'status': newValue!.name});
                              setState(() {
                                _currentServerStatus = newValue;
                              });
                            }),
                        RadioListTile(
                            title: const Text('접근 불가'),
                            value: ServerStatus.error,
                            groupValue: _currentServerStatus,
                            onChanged: (newValue) async {
                              await FirebaseDatabase.instance
                                  .ref('server')
                                  .update({'status': newValue!.name});
                              setState(() {
                                _currentServerStatus = newValue;
                              });
                            }),
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
