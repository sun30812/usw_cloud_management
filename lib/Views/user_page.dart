import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:usw_cloud_management/Model/types.dart';
import 'package:usw_cloud_management/Model/user.dart';
import 'package:usw_cloud_management/Views/style.dart';

/// 관리자가 사용자들에 대한 정보를 볼 때 나타나는 화면이다.
///
/// 관리자로 포털에 로그인한 경우 사용자 관리 항목을 탭 하였을 시 나타난다.
/// Google의 *Firebase*를 이용하여 실시간 데이터베이스에 접근해서 쿼리작업을 수행한다.
///
/// ## 같이보기
/// - [User]
/// - [UserQueryType]
/// - [FirebaseDatabase]
class UserPage extends StatefulWidget {
  /// 쿼리하고자 하는 사용자 종류
  final UserQueryType userListType;

  /// 모든 사용자 종류를 [DropdownMenuItem]으로 변환한 것
  final List<DropdownMenuItem> userQueryTypeMenuItems = UserQueryType.values
      .map((value) => DropdownMenuItem(
            value: value,
            child: Text(value.stringValue),
          ))
      .toList();

  UserPage({required this.userListType, Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late UserQueryType _queryType;

  @override
  void initState() {
    super.initState();
    _queryType = widget.userListType;
  }

  /// `Firebase`로부터 쿼리를 수행후 결과를 가져오는 메서드
  ///
  /// Google의 *Firebase*의 실시간 데이터 베이스를 통해 **자료 변동 여부를 확인**하면서
  /// 가져온다. [queryType]에 따라 쿼리를 수행하며 수신된 자료는 화면에 출력되지만
  /// 계속 확인을 통해 자료 변동 시 다시 수신한다.
  ///
  /// ## 같이보기
  ///
  /// - [UserQueryType]
  /// - [FirebaseDatabase]
  /// - [Stream]
  Stream<DatabaseEvent> _getQuery(UserQueryType queryType) {
    switch (queryType) {
      case UserQueryType.all:
      case UserQueryType.signup:
      case UserQueryType.requiredReset:
        return FirebaseDatabase.instance
            .ref('users')
            .orderByChild('status')
            .equalTo(queryType.firebaseStorageStatus)
            .onValue;
      case UserQueryType.locked:
        return FirebaseDatabase.instance
            .ref('users')
            .orderByChild('isLocked')
            .equalTo(true)
            .onValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController userId = TextEditingController();
    TextEditingController userName = TextEditingController();
    TextEditingController studentId = TextEditingController();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('사용자 추가'),
                    content: Column(
                      children: [
                        const Text('새로 추가할 사용자의 정보를 입력하세요.'),
                        Row(
                          children: [
                            const Text('사용자 ID: '),
                            Expanded(
                                child: TextField(
                              controller: userId,
                            ))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('이름: '),
                            Expanded(
                                child: TextField(
                              controller: userName,
                            ))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('학번: '),
                            Expanded(
                                child: TextField(
                              keyboardType: TextInputType.number,
                              controller: studentId,
                            ))
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소')),
                      TextButton(
                          onPressed: () async {
                            if (userId.text.isEmpty ||
                                studentId.text.isEmpty ||
                                userName.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('경고'),
                                  content: const Text('모든 항목을 입력해야 합니다.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('확인'))
                                  ],
                                ),
                              );
                              return;
                            } else if (int.tryParse(studentId.text) == null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('경고'),
                                  content: const Text('학번은 숫자만 입력해야합니다.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('확인'))
                                  ],
                                ),
                              );
                              return;
                            }
                            DatabaseReference ref = FirebaseDatabase.instance
                                .ref('users/${userId.text}');
                            await ref.set({
                              "isLocked": false,
                              "status": "normal",
                              "studentId": int.parse(studentId.text),
                              "username": userName.text,
                            }).then((value) => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('사용자 추가 완료!'))));
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('추가')),
                    ],
                  );
                }),
            child: const Icon(Icons.add)),
        appBar: AppBar(title: const Text('사용자 관리')),
        body: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('사용자 분류: '),
                  DropdownButton(
                      value: _queryType,
                      items: widget.userQueryTypeMenuItems,
                      onChanged: (newValue) => setState(() {
                            _queryType = newValue;
                          })),
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder<DatabaseEvent>(
              stream: _getQuery(_queryType),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                } else {
                  List<User> userList = [];
                  dynamic serverValue =
                      (snapshot.data as DatabaseEvent).snapshot.value;
                  if (serverValue == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.do_disturb),
                          Text('해당 조건을 만족하는 사용자가 존재하지 않습니다.'),
                        ],
                      ),
                    );
                  }
                  (serverValue as Map).forEach((key, value) {
                    userList.add(User.fromFirebaseDatabase(key, value));
                  });
                  return ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (BuildContext context, int counter) {
                        User user = userList[counter];
                        return UserInfoCard(
                            id: user.id,
                            name: user.username,
                            status: user.status,
                            studentId: user.studentId,
                            isLocked: user.isLocked);
                      });
                }
              },
            ))
          ],
        ));
  }
}
