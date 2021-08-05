import 'dart:async';

import 'package:chapter10/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'tab_page.dart';

class LoginPage extends StatelessWidget {

  // 구글 로그인을 위한 객체
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 파이어베이스 인증 정보를 가지는 객체
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Instagram Clone',
              style: GoogleFonts.pacifico(
                fontSize: 40.0,
              ),
            ),
            Container(
              margin: EdgeInsets.all(50.0),
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _handleSignIn().then((user) {
                  print(user);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TabPage(user)),
                  );
                });
              },

            ),
          ],
        ),
      ),
    );
  }

  // 구글 로그인을 수행하고 FirebaseUser의 credential을 반환
  Future<User> _handleSignIn() async {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user!;
  }

}
