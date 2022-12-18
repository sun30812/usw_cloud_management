import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:usw_cloud_management/Model/types.dart';

import '../Model/user.dart';

/// 사용자가 새로운 요청사항을 작성할 시 확인 가능한 페이지이다.
///
/// 이 페이지는 관리자 또한 요청사항 작성 시 사용이 가능하다. 요청 종류와 관계없이
/// 동일한 안내문이 사용된다.
class NewRequestPage extends StatefulWidget {
  final RequestQueryType requestQueryType;

  const NewRequestPage({required this.requestQueryType, super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final TextEditingController _controller = TextEditingController();

  final List<DropdownMenuItem> requestQueryTypeMenuItems = RequestQueryType
      .values
      .map((value) =>
          DropdownMenuItem(value: value, child: Text(value.stringValue)))
      .toList();

  Future<String?> getCurrentUser() {
    const storage = FlutterSecureStorage();
    return storage.read(key: 'currentUser');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 요청 생성'),
        actions: [
          IconButton(
              onPressed: () async {
                String? userJson = await getCurrentUser();
                if (userJson == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('올바르지 않은 경로로 접속되어 메인으로 돌아갑니다.')));
                    context.go('/');
                  }
                  return;
                }
                User user = User.fromJson(jsonDecode(userJson));
                await FirebaseDatabase.instance
                    .ref('request/${user.id}')
                    .push()
                    .set({
                  'id': user.id,
                  'kind': widget.requestQueryType.name,
                  'content': _controller.text
                }).then((value) {
                  context.go('/');
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('요청이 전송되었습니다.')));
                });
              },
              icon: const Icon(Icons.send_outlined))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  DropdownButton(
                      value: widget.requestQueryType,
                      items: requestQueryTypeMenuItems,
                      onChanged: null),
                  ListTile(
                    leading: const Icon(Icons.note_outlined),
                    title: Text(
                      '요청 내용',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                    ),
                  )
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(
                      '작성 시 아래 내용을 포함해주세요',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const ListTile(
                    title: Text('패키지 이름'),
                    subtitle: Text('패키지의 이름을 적어주세요.'),
                  ),
                  const ListTile(
                    title: Text('사용 목적'),
                    subtitle: Text('해당 패키지가 필요한 이유를 적어주세요.'),
                  ),
                  const ListTile(
                    title: Text('(복원 시)복원이 필요한 파일의 절대경로'),
                    subtitle: Text(
                        '복원이 필요한 파일의 절대경로를 적어주세요. 기억이 안난다면 파일 이름이라도 적어보세요.'),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.do_not_touch_outlined),
                    title: Text(
                      '작성 시 아래 내용은 넣지 마세요',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const ListTile(
                    title: Text('요청자 이름/학번/ID'),
                    subtitle: Text('요청을 제출하면 관리자에게 자동으로 요청자의 ID가 전달됩니다.'),
                  ),
                  const ListTile(
                    title: Text('계정의 비밀번호'),
                    subtitle: Text('유효한 관리자면 사용자의 비밀번호 없이 모든 작업이 가능합니다.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
