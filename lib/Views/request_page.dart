import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:usw_cloud_management/Model/types.dart';
import 'package:usw_cloud_management/Views/style.dart';
import '../Model/request.dart';

/// 요청 작업을 확인할 수 있는 페이지이다.
///
/// 관리자는 이 페이지에서 사용자들이 요청한 것을 확인할 수 있다.
/// 일반 사용자는 본인이 요청한 내역에 대해서만 조회가 가능하다.
class RequestPage extends StatefulWidget {
  final RequestQueryType requestQueryType;
  final String? user;
  final List<DropdownMenuItem> requestQueryTypeMenuItems = RequestQueryType
      .values
      .map((value) =>
          DropdownMenuItem(value: value, child: Text(value.stringValue)))
      .toList();

  RequestPage({required this.requestQueryType, this.user, Key? key})
      : super(key: key);

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  late RequestQueryType _queryType;

  /// 요청 분류에 따라 쿼리를 진행하는 함수
  ///
  /// [queryType]에 따라 특정 쿼리를 진행하기도 하고 쿼리 없이 모든 데이터를 출력하기도 합니다.
  /// [queryType]이 [RequestQueryType.all]이면 쿼리를 진행하지 않고,
  /// 이외의 경우에는 쿼리를 진행한다.
  ///
  /// ## 같이보기
  /// - [RequestQueryType]
  Stream<DatabaseEvent> _getQuery(RequestQueryType queryType) {
    if (_queryType == RequestQueryType.all) {
      return FirebaseDatabase.instance
          .ref('request${widget.user != null ? '/${widget.user!}' : ''}')
          .onValue;
    } else {
      return FirebaseDatabase.instance
          .ref('request${widget.user != null ? '/${widget.user!}' : ''}')
          .orderByChild('kind')
          .equalTo(queryType.name)
          .onValue;
    }
  }

  @override
  void initState() {
    super.initState();
    _queryType = widget.requestQueryType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요청작업'),
      ),
      body: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('요청 분류: '),
                DropdownButton(
                    value: _queryType,
                    items: widget.requestQueryTypeMenuItems,
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
                List<Request> requestList = [];
                dynamic serverValue =
                    (snapshot.data as DatabaseEvent).snapshot.value;
                if (serverValue == null || serverValue == '') {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.do_disturb),
                        Text('해당 조건을 만족하는 요청이 존재하지 않습니다.'),
                      ],
                    ),
                  );
                }
                (serverValue as Map).forEach((key, value) {
                  requestList.add(Request.fromFirebaseDatabase(key, value));
                });
                return ListView.builder(
                    itemCount: requestList.length,
                    itemBuilder: (BuildContext context, int counter) {
                      Request request = requestList[counter];
                      return RequestInfoCard(
                        isAdmin: widget.user == null,
                        requestId: request.requestId,
                        id: request.id,
                        kind: request.kind,
                        content: request.content,
                      );
                    });
              }
            },
          ))
        ],
      ),
    );
  }
}
