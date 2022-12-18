import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:usw_cloud_management/Model/types.dart';

/// 공지사항 카드이다.
///
/// 대시보드 상단에 존재하는 공지사항 카드위젯이다. 사용자의 경우 카드의 내용을 확인할
/// 수 만 있으며, 관리자의 경우 내용 편집이 가능하다.
class NoticeCard extends StatefulWidget {
  /// 해당 공지사항 카드가 관리자에게 보여지는지 여부이다.
  ///
  /// `null`인 경우이거나 `false`인 경우 사용자 입장에서 공지사항 카드를 제공하기 때문에
  /// 수정 기능이 제공되지 않는다. 그러나 `true`의 경우 수정버튼을 통해 공지사항 수정이 가능하다.
  final bool? isAdmin;

  /// 공지사항 카드를 생성한다.
  ///
  /// 공지사항을 보여주는 카드위젯을 생성할 수 있다. [isAdmin]을 통해 관리자에게
  /// 보여지는 카드위젯인지 아닌지를 결정할 수 있다.
  const NoticeCard({this.isAdmin, Key? key}) : super(key: key);

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 23.0,
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0)),
                      Text(
                        '공지사항',
                        style: TextStyle(
                            fontSize: 23.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (widget.isAdmin != null && widget.isAdmin!)
                    IconButton(
                        onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('공지사항 등록'),
                                content: Column(
                                  children: [
                                    const Text('공지사항에 등록할 내용을 입력합니다.'),
                                    TextField(
                                      controller: _controller,
                                      minLines: 1,
                                      maxLines: 23,
                                    )
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () async {
                                        if (_controller.text.isEmpty) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const AlertDialog(
                                              title: Text('경고'),
                                              content: Text('내용이 입력되지 않았습니다.'),
                                            ),
                                          );
                                        }
                                        FirebaseDatabase.instance
                                            .ref('notice')
                                            .set(_controller.text)
                                            .then((value) => ScaffoldMessenger
                                                    .of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        '공지사항에 등록되었습니다.'))));
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('확인'))
                                ],
                              ),
                            ),
                        icon: const Icon(Icons.edit_outlined))
                ],
              ),
              StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance.ref('notice').onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator.adaptive();
                  } else {
                    var data = snapshot.data!.snapshot.value;
                    String content = '공지된 내용 없음';
                    if (data != null) {
                      content = data.toString();
                    }
                    return Text(
                      content,
                      style: const TextStyle(fontSize: 18.0),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// 대시보드에 사용되는 기본 카드 형태이다.
///
/// 대시보드에 나타낼 카드형태의 위젯으로 [icon]을 통해 최상단의
/// 제목 부분에 나타날 아이콘을 지정할 수 있다.
/// 그리고 [title]은 아이콘 오른쪽의 제목에 해당한다.
///
/// 아래의 내용부분은 [content]로 지정이 가능하며 내용부분의 위젯이 많은 경우
/// 스크롤이 가능하도록 지정된다.
class DynamicCard extends StatefulWidget {
  /// 카드 위젯의 최상단에 표시되는 제목에서 가장 왼쪽에 위치한 아이콘
  final IconData icon;

  /// 카드 위젯의 최상단에 나오는 제목
  final String title;

  /// 카드 위젯에서 제목의 하단에 배치할 수 있는 위젯
  final Widget content;
  const DynamicCard(
      {required this.icon,
      required this.title,
      required this.content,
      Key? key})
      : super(key: key);

  @override
  State<DynamicCard> createState() => _DynamicCardState();
}

class _DynamicCardState extends State<DynamicCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 23.0,
                  ),
                  const Padding(padding: EdgeInsets.only(right: 5.0)),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 23.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              widget.content
            ],
          ),
        ),
      ),
    );
  }
}

/// 사용자 관리 페이지에서 사용되는 카드 형태의 위젯이다.
///
/// 계정이 잠겨있는지 여부에 따라 디자인 적인 차이가 존재하며, 간략한 정보를
/// 사용자들에 대한 간략한 정보를 출력하는데 쓰인다.
///
/// ## 같이보기
/// - [UserType]
class UserInfoCard extends StatefulWidget {
  /// 사용자의 서버 ID
  final String id;

  /// 사용자의 표시이름
  final String name;

  /// 사용자 계정의 상태
  final UserType status;

  /// 사용자의 학번
  final int studentId;

  /// 사용자 계정의 잠금여부
  final bool isLocked;

  /// 사용자 관리 페이지에서 사용되는 카드 형태의 위젯이다.
  ///
  /// 사용자 관리 페이지에서 나타낼 카드형태의 위젯으로 사용자 정보가 담긴 카드를 만들 수 있다.
  /// [id]는 최상단에 사용자 아이콘 오른쪽에 표시된다.
  /// [name]은 이름에 해당되며 [studentId]는
  /// 학번에 해당된다.
  ///
  /// [status]는 해당 유저의 상태를 지정한다.
  /// 마지막으로 [isLocked]는 계정의 잠금 여부를 알려주며 잠긴 계정일 시 우측상단에
  /// 자물쇠 아이콘과 같이 잠긴 계정이라는 문구가 출력된다.
  const UserInfoCard(
      {required this.id,
      required this.name,
      required this.status,
      required this.studentId,
      required this.isLocked,
      Key? key})
      : super(key: key);

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [const Icon(Icons.person_outline), Text(widget.id)],
                ),
                if (widget.isLocked)
                  TextButton(
                    style: const ButtonStyle(
                        foregroundColor:
                            MaterialStatePropertyAll(Colors.black)),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('잠긴 계정 안내'),
                        content: Text('서버에 로그인 하지 못하게 잠근 상태를 잠긴 계정이라고 표시합니다.'
                            '\n[계정 잠금/잠금 해제]버튼을 누르시면 계정의 잠금 상태를 즉시 변경할 수 있습니다.'),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock_outline),
                        Text('잠긴 계정'),
                      ],
                    ),
                  )
              ],
            ),
            Text('이름: ${widget.name}'),
            Text('학번: ${widget.studentId}'),
            if (widget.status == UserType.normal)
              Row(
                children: [
                  OutlinedButton(
                      onPressed: () => setState(() {
                            FirebaseDatabase.instance.ref('users').update(
                                {'/${widget.id}/isLocked': !widget.isLocked});
                          }),
                      child: const Text('계정 잠금 / 잠금해제')),
                  OutlinedButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('경고'),
                              content: const Text(
                                  '이 작업은 사용자를 삭제하게 되고 되돌릴 수 없습니다. 계속 하시겠습니까?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소')),
                                TextButton(
                                    onPressed: () async {
                                      await FirebaseDatabase.instance
                                          .ref('users/${widget.id}')
                                          .remove()
                                          .then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text('계정을 삭제하였습니다.')));
                                      });
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('확인'))
                              ],
                            ),
                          ),
                      child: const Text('계정 삭제')),
                ],
              )
          ],
        ),
      ),
    );
  }
}

/// 요청 관리 페이지에서 사용되는 카드 형태의 위젯이다.
class RequestInfoCard extends StatefulWidget {
  /// 관리자 여부를 나타낸다.
  final bool isAdmin;

  /// 사용자의 ID를 나타낸다.
  final String id;

  /// 요청 관련 고유 ID이다
  final String requestId;

  /// 요청 내용에 해당되는 부분이다.
  final String content;

  /// [RequestQueryType]을 통해 요청 종류를 나타내는 부분이다.
  final RequestQueryType kind;
  const RequestInfoCard(
      {required this.isAdmin,
      required this.id,
      required this.requestId,
      required this.kind,
      required this.content,
      Key? key})
      : super(key: key);

  @override
  State<RequestInfoCard> createState() => _RequestInfoCardState();
}

class _RequestInfoCardState extends State<RequestInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [const Icon(Icons.person_outline), Text(widget.id)],
                ),
                requestKindInfo(context, widget.kind)
              ],
            ),
            Text(widget.content),
            Row(
              children: [
                if (widget.isAdmin) ...[
                  OutlinedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('요청 수락')),
                  OutlinedButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('거절 사유'),
                              content:
                                  const Text('거절 사유를 입력해야 요청을 거절할 수 있습니다.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소')),
                                TextButton(
                                    onPressed: () async {
                                      if (mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('확인'))
                              ],
                            ),
                          ),
                      child: const Text('요청 거절')),
                ],
                if (!widget.isAdmin)
                  OutlinedButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('삭제하기'),
                              content: const Text('해당 요청을 삭제합니다. 계속하시겠습니까?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('취소')),
                                TextButton(
                                    onPressed: () async {
                                      await FirebaseDatabase.instance
                                          .ref(
                                              'request/${widget.id}/${widget.requestId}')
                                          .remove()
                                          .then((value) =>
                                              Navigator.of(context).pop());
                                    },
                                    child: const Text('확인'))
                              ],
                            ),
                          ),
                      child: const Text('요청 삭제'))
              ],
            )
          ],
        ),
      ),
    );
  }

  /// 요청 종류를 알려주는 위젯
  ///
  /// 요청 종류를 알려주는 위젯으로 요청 종류에 대한 것을 간략히 알려준다.
  /// 단순히 요청 종류를 보여주는 목적 이외에 탭 하면 요청 항목에 대한 설명을 볼
  /// 수 있도록 하였다.
  ///
  /// [queryType]을 통해 요청 종류를 확인해서 상황에 맞는 아이콘과 설명을 제공한다.
  ///
  /// ## 같이보기
  ///
  /// - [RequestQueryType]
  TextButton requestKindInfo(BuildContext context, RequestQueryType queryType) {
    switch (queryType) {
      case RequestQueryType.installation:
        return TextButton(
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.black)),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('설치 요청 안내'),
              content: Text('특정 패키지 설치를 요구하는 요청을 [설치 요청]이라 표시합니다.'),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.get_app_outlined),
              Text('설치 요청'),
            ],
          ),
        );
      case RequestQueryType.restore:
        return TextButton(
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.black)),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('복원 요청 안내'),
              content: Text('특정 파일의 복원을 요구하는 내용의 경우 [복원 요청]이라 표시합니다.'),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.restore),
              Text('복원 요청'),
            ],
          ),
        );
      default:
        return TextButton(
          style: const ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.black)),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('기타 요청 안내'),
              content: Text('복원이나 설치 요청이 아닌 다른 요청의 경우 [기타 요청]으로 표시됩니다.'
                  '\n만일 비밀번호 초기화 요청을 한 경우 이 곳에 요청 결과가 표시됩니다.'),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.chat_bubble_outline),
              Text('기타 요청'),
            ],
          ),
        );
    }
  }
}

/// 존재하지 않는 페이지를 방문할 시 화면이다.
class NotFoundErrorPage extends StatelessWidget {
  const NotFoundErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('오류: 존재하지 않는 페이지'),
          backgroundColor: Colors.orangeAccent,
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '404 Not Found',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '현재 존재하지 않는 페이지로 접속하셨습니다.\n아래와 같은 이유로 해당 문제가 발생하였습니다.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const ListTile(
                      leading: Icon(Icons.link_off_outlined),
                      title: Text('주소창에 존재하지 않는 주소를 작성한 경우'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.toggle_off_outlined),
                      title: Text('개발자가 아직 구현하지 않은 기능에 접근한 경우'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.adb_outlined),
                      title: Text('개발자가 실수한 경우'),
                    ),
                    const Divider(),
                    const Text('아래 버튼을 눌러 조치를 취하세요'),
                    ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('(오류인 것으로 보인다면) 개발자에게 이메일 보내기'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('개발자에게 메일 보내기'),
                              content: Column(
                                children: [
                                  const Text(
                                      '아래 주소로 현재 사이트 주소와 문제 사항을 보내주세요.\n'),
                                  Row(
                                    children: [
                                      const Text(
                                          '이메일 주소: orgsun30812+usw_cloud_portal@gmail.com'),
                                      IconButton(
                                          onPressed: () => Clipboard.setData(
                                                  const ClipboardData(
                                                      text:
                                                          'orgsun30812+usw_cloud_portal@gmail.com'))
                                              .then((value) => ScaffoldMessenger
                                                      .of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          '이메일 주소가 복사되었습니다.')))),
                                          icon: const Icon(Icons.copy))
                                    ],
                                  )
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('확인'))
                              ],
                            );
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('대시보드로 이동'),
                      onTap: () => context.go('/'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
