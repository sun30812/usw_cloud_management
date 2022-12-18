import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usw_cloud_management/Model/types.dart';
import 'package:usw_cloud_management/Model/user.dart' as usw_user;
import 'package:go_router/go_router.dart';

/// 제일 먼저 앱을 실행하면 보이는 로그인 화면이다.
///
/// 로그인 화면에 해당되는 영역으로 배경이랑 수원대학교 로고를 출력하는 영역이다.
/// 실제 로그인과 관련된 동작은 [LoginBox]가 담당하고 있다.
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/cloud-wallpaper.jpg'))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Image.asset('images/usw-cloud-logo-v2.png'),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LoginBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 로그인 화면 중앙에 위치한 실제 로그인 위젯이다.
///
/// 로그인화면 중앙에 위치하였으며 실제 로그인이 진행되는 위젯이다.
/// 현재 로그인 방식은 두가지로 나뉘며(관리자, 사용자) 관리자 로그인은 Google로
/// 로그인을 지원하고, 사용자의 경우 본인의 서버 ID를 입력하면 로그인되는 형태이다.
/// Google로 로그인이나 사용자 로그인은 Google의 *Firebase*를 이용하여 구현되었다.
class LoginBox extends StatefulWidget {
  const LoginBox({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginBox> createState() => _LoginBoxState();
}

class _LoginBoxState extends State<LoginBox> with TickerProviderStateMixin {
  late TabController _controller;
  final TextEditingController _serverId = TextEditingController();

  Future<UserCredential> signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430,
      height: 300,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Container(
            color: Colors.grey,
            child: TabBar(
              controller: _controller,
              tabs: [
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text(
                    '괸라자 로그인',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text(
                    '사용자 로그인',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              indicator: const BoxDecoration(color: Colors.white),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
            ),
          ),
          Expanded(
              child: TabBarView(
            controller: _controller,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      '지원되는 제공 업체 사이트의 로그인을 통해 관리자 계정으로 로그인이 '
                      '가능합니다. 관리자가 아닌 경우 로그인해도 관리자 페이지로 로그인되지 않습니다.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          UserCredential userCred = await signInWithGoogle();
                          if (userCred.user != null &&
                              userCred.user!.uid ==
                                  const String.fromEnvironment(
                                      'bjO4FHKaGQUdbumUF9Fua3Eo7Kh2')) {
                            if (mounted) {
                              context.go('/dashboard');
                            }
                          }
                        },
                        style: ButtonStyle(backgroundColor:
                            MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return const Color.fromRGBO(0, 54, 112, 0.5);
                          }
                          return const Color.fromRGBO(0, 54, 112, 1.0);
                        })),
                        child: const Text(
                          'Google로 로그인',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      '사용자는 서버의 ID만 입력하여 빠르게 로그인 가능합니다. 단, 이 기능은'
                      ' 보안 문제로 인해서 일부 기능이 제한됩니다.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const Text(
                      '※ 관리자는 해당 로그인 방식을 사용할 수 없습니다.',
                      style: TextStyle(fontSize: 15.0, color: Colors.red),
                    ),
                    TextField(
                      controller: _serverId,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.lock_outline),
                          hintText: '서버 아이디 입력',
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_serverId.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('아이디가 입력되지 않았습니다.')));
                            return;
                          }
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => Dialog(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Row(
                                        children: const [
                                          CircularProgressIndicator(),
                                          Text('  로그인 하는 중..')
                                        ],
                                      ),
                                    ),
                                  ));
                          DataSnapshot ref = await FirebaseDatabase.instance
                              .ref('/users/${_serverId.text}')
                              .get();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                          if (!ref.exists) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('계정이 존재하지 않습니다.')));
                            }
                            return;
                          }
                          usw_user.User user =
                              usw_user.User.fromFirebaseDatabase(
                                  ref.key, ref.value);
                          if (user.status == UserType.unregistered) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('로그인 오류'),
                                content: const Text(
                                    '아직 계정에 대한 심사가 진행중입니다. 심사가 완료되면 로그인이 가능합니다.'
                                    '\n영업일 기준 3일 이후에도 이 메세지가 보이는 경우 관리자에게 문의하세요.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('확인'))
                                ],
                              ),
                            );
                          } else {
                            const storage = FlutterSecureStorage();
                            await storage.write(
                                key: 'currentUser', value: jsonEncode(user));
                            if (mounted) {
                              context.go('/user-dashboard');
                            }
                          }
                        },
                        style: ButtonStyle(backgroundColor:
                            MaterialStateColor.resolveWith((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return const Color.fromRGBO(0, 54, 112, 0.5);
                          }
                          return const Color.fromRGBO(0, 54, 112, 1.0);
                        })),
                        child: const Text(
                          '로그인',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
