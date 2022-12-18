import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usw_cloud_management/Views/login.dart';
import 'package:usw_cloud_management/Views/new_request_page.dart';
import 'package:usw_cloud_management/Views/request_page.dart';
import 'package:usw_cloud_management/Views/server_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:usw_cloud_management/Views/style.dart';
import 'package:usw_cloud_management/Views/user_dashboard.dart';
import 'Model/types.dart';
import 'Views/dashboard.dart';
import 'Views/user_page.dart';
import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      title: '수원대 클라우드 포털',
    );
  }

  /// 앱에서 사용되는 각 페이지들을 각 클래스에 연결한 것이다.
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          const storage = FlutterSecureStorage();
          String? user = await storage.read(key: 'currentUser');
          if (FirebaseAuth.instance.currentUser != null) {
            return '/dashboard';
          } else if (user != null) {
            return '/user-dashboard';
          }
          return null;
        },
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
          path: '/dashboard',
          redirect: (context, state) {
            if (FirebaseAuth.instance.currentUser == null) {
              return '/';
            }
            return null;
          },
          routes: [
            GoRoute(
                path: 'users',
                builder: (BuildContext context, GoRouterState state) {
                  return UserPage(
                      userListType: state.extra != null
                          ? state.extra as UserQueryType
                          : UserQueryType.all);
                }),
            GoRoute(
                path: 'request',
                builder: (BuildContext context, GoRouterState state) {
                  return RequestPage(
                    requestQueryType: state.extra != null
                        ? state.extra as RequestQueryType
                        : RequestQueryType.installation,
                  );
                }),
            GoRoute(
                path: 'request/new',
                builder: (BuildContext context, GoRouterState state) {
                  return NewRequestPage(
                    requestQueryType: state.extra != null
                        ? state.extra as RequestQueryType
                        : RequestQueryType.installation,
                  );
                }),
            GoRoute(
                path: 'serverStatusSetting',
                builder: (BuildContext context, GoRouterState state) {
                  return const ServerSettingsPage();
                }),
          ],
          builder: (BuildContext context, GoRouterState state) {
            return const Dashboard();
          }),
      GoRoute(
          path: '/user-dashboard',
          redirect: (context, state) async {
            const storage = FlutterSecureStorage();
            String? user = await storage.read(key: 'currentUser');
            if (user == null) {
              return '/';
            }
            return null;
          },
          builder: (BuildContext context, GoRouterState state) {
            return const UserDashboard();
          },
          routes: [
            GoRoute(
                path: 'request',
                builder: (BuildContext context, GoRouterState state) {
                  return RequestPage(
                      requestQueryType:
                          (state.extra as Map<String, dynamic>)['type'] != null
                              ? (state.extra as Map<String, dynamic>)['type']
                                  as RequestQueryType
                              : RequestQueryType.installation,
                      user: (state.extra as Map<String, dynamic>)['user']);
                }),
            GoRoute(
                path: 'request/new',
                builder: (BuildContext context, GoRouterState state) {
                  return NewRequestPage(
                    requestQueryType: state.extra != null
                        ? state.extra as RequestQueryType
                        : RequestQueryType.installation,
                  );
                }),
          ]),
    ],
    errorBuilder: (context, state) => const NotFoundErrorPage(),
  );
}
