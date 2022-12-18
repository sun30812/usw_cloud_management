import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usw_cloud_management/Model/server_info.dart';
import 'package:usw_cloud_management/Model/user.dart';
import 'package:usw_cloud_management/Views/style.dart';
import 'package:go_router/go_router.dart';
import '../Model/types.dart';

/// 사용자로써 포털에 접근할 때 보여지는 페이지이다.
///
/// 사용자 계정으로 로그인 하면 관리자가 게시한 공지사항이나 요청사항을 생성할 수 있는 페이지로 이동한다.
class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Future<String?> getCurrentUser() {
    const storage = FlutterSecureStorage();
    return storage.read(key: 'currentUser');
  }

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
        title: const Text('수원대 클라우드 포털'),
        actions: [
          IconButton(
            onPressed: () {
              const storage = FlutterSecureStorage();
              storage.delete(key: 'currentUser').then((_) => context.go('/'));
            },
            icon: const Icon(Icons.power_settings_new_outlined),
            tooltip: '로그아웃',
          )
        ],
      ),
      body: FutureBuilder<String?>(
          future: getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [CircularProgressIndicator.adaptive()],
                ),
              );
            } else {
              Map<String, dynamic> userMap = jsonDecode(snapshot.data!);
              User user = User.fromJson(userMap);
              return Column(
                children: [
                  DynamicCard(
                      icon: Icons.computer_outlined,
                      title: '서버 접속 안내',
                      content: StreamBuilder<DatabaseEvent>(
                          stream:
                              FirebaseDatabase.instance.ref('server').onValue,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            } else {
                              Map<String, dynamic> data = snapshot
                                  .data!.snapshot.value as Map<String, dynamic>;
                              ServerInfo serverInfo =
                                  ServerInfo.fromFirebase(data);
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
                  const NoticeCard(isAdmin: false),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: getCrossAxisCount(
                          MediaQuery.of(context).size.width.toInt() - 300),
                      childAspectRatio: getAspectRatio(
                          MediaQuery.of(context).size.width.toInt() - 300),
                      children: [
                        DynamicCard(
                          icon: Icons.people_outline,
                          title: '내 정보',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('여기에서 내 정보를 확인하거나 '
                                  '비밀번호(서버) 초기화 요청을 할 수 있습니다.'),
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(user.id),
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock_outline),
                                title: Text(user.username),
                              ),
                              ListTile(
                                leading:
                                    const Icon(Icons.assignment_ind_outlined),
                                title: Text(user.studentId.toString()),
                              ),
                              OutlinedButton(
                                  onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('비밀번호 초기화하기'),
                                            content: const Text(
                                                '비밀번호 초기화를 관리자에게 요청합니다.\n'
                                                '요청 결과는 내 요청기록 보기에서 확인 할 수 있습니다. 계속하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('취소')),
                                              TextButton(
                                                  onPressed: () {
                                                    FirebaseDatabase.instance
                                                        .ref('users/${user.id}')
                                                        .update({
                                                      'status': 'needReset'
                                                    }).then((value) {
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      '요청이 전송되었습니다.')));
                                                    });
                                                  },
                                                  child: const Text('확인')),
                                            ],
                                          );
                                        },
                                      ),
                                  child: const Text('비밀번호 초기화 요청하기')),
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
                                  title: const Text('내 요청기록 보기'),
                                  onTap: () => context.push('/user-dashboard/request',
                                      extra: {'type': RequestQueryType.all, 'user': user.id}),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.get_app_outlined),
                                  title: const Text('패키지 설치 요청하기'),
                                  onTap: () => context.push(
                                      '/user-dashboard/request/new',
                                      extra: RequestQueryType.installation),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.restore),
                                  title: const Text('파일 복원 요청하기'),
                                  onTap: () => context.go(
                                      '/user-dashboard/request/new',
                                      extra: RequestQueryType.restore),
                                ),
                                ListTile(
                                  leading:
                                      const Icon(Icons.chat_bubble_outline),
                                  title: const Text('기타 사항 요청하기'),
                                  onTap: () => context.go(
                                      '/user-dashboard/request/new',
                                      extra: RequestQueryType.extra),
                                ),
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              );
            }
          }),
    );
  }
}
