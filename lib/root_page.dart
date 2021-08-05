import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loading_page.dart';
import 'login_page.dart';
import 'tab_page.dart';

class RootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('root_page created');
    return _handleCurrentScreen();
  }

  Widget _handleCurrentScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot);

        // 연결 상태가 기다리는 중이라면, 로딩 페이지를 반환
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        // 연결이 되었고,
        } else {
          // 데이터가 존재한다면,
          if (snapshot.hasData) {
            return TabPage(snapshot.data);
          }
          // Firebase auth 인증 객체를 얻을 수 없다. 즉 인증이 되지 않았다.
          return LoginPage();
        }
      },
    );
  }
}
