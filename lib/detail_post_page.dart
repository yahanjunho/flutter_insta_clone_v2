import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailPostPage extends StatelessWidget {
  DocumentSnapshot document;
  final User user;

  DetailPostPage(this.document, this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('둘러보기'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(document['userPhotoUrl']),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            document['email'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: _followingStream(),
                            builder: (context, snapshot) {
                              // following 컬렉션에서, 내 이메일 주소로 following되는 document 자체가 없는 경우
                              if (!snapshot.hasData) {
                                return Text('로딩중');
                              }

                              var data = snapshot.data;
                              var test = data!.data() as Map;

                              print('tttttt');
                              print(test);
                              print(document['email']);
                              print(test['test@test.com']);
                              print('tttttt');

                              if (
                                // following 컬렉션에서 내 이메일 주소의 document는 있지만, document 내용이 null 인 경우
                                test == null ||
                                // 작성된 현재 글의 작성자 email이 내 document에 following으로 등록되어 있지 않은 경우,
                                test[document['email']] == null ||
                                // 작성된 현재 글의 작성자 email이 내 document에 following으로 등록되어 있으나, 그 값이 false인 경우
                                test[document['email']] == false
                              ) {
                                return GestureDetector(
                                  onTap: _follow,
                                  child: Text(
                                    "팔로우",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: _unfollow,
                                child: Text(
                                  "언팔로우",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Text(document['displayName']),
                    ],
                  ),
                )
              ],
            ),
          ),
          Hero(
            tag: document.id,
            child: Image.network(
              document['photoUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(document['contents']),
          ),
        ],
      ),
    );
  }


  // 팔로우
  void _follow() {
    // 내가 팔로잉하는거
    FirebaseFirestore.instance
        .collection('following')
        .doc(user.email)
        .set({document['email']: true});

    // 팔로워가 나를 팔로잉하는거
    FirebaseFirestore.instance
        .collection('follow')
        .doc(document['email'])
        .set({user.email!: true});
  }

  // 언팔로우
  void _unfollow() {
    FirebaseFirestore.instance
        .collection('following')
        .doc(user.email)
        .set({document['email']: false});

    FirebaseFirestore.instance
        .collection('follow')
        .doc(document['email'])
        .set({user.email!: false});
  }

  // 팔로잉 상태를 얻는 스트림(현재 내가 팔로잉하고 있는 사람들의 정보를 다 가져온다)
  Stream<DocumentSnapshot> _followingStream() {
    return FirebaseFirestore.instance
        .collection('following')
        .doc(user.email)
        .snapshots();
  }
}
