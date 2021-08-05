import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'comment_page.dart';

class FeedWidget extends StatefulWidget {
//  final Map<String, dynamic> document = {
//    'userPhotoUrl': '',
//    'email': 'test@test.com',
//    'displayName': '더미',
//    'comment': 100,
//  };

  final DocumentSnapshot document;
  final User user;

  FeedWidget(this.document, this.user);

  @override
  _FeedWidgetState createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('tttttxxxxxxxxx');
    var test = widget.document.data() as Map;
    print(test['likedUsers']);
    print(test['email']);
    print(widget.user.email);
    print(test['likedUsers']?.contains(test['email']));
    print('tttttxxxxxxxxxx');

    var commentCount = test['commentCount'] ?? 0;
    print(commentCount);

    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(test['userPhotoUrl']),
          ),
          title: Text(
            test['email'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.more_vert),
        ),
        Image.network(
          test['photoUrl'],
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              test['likedUsers']?.contains(widget.user.email)
                  ?? false
                  ? GestureDetector(
                      onTap: _unlike,
                      child: Icon(Icons.favorite, color: Colors.red)
                    )
                  : GestureDetector(
                      onTap: _like,
                      child: Icon(Icons.favorite_border)
                    ),
              SizedBox(
                width: 8.0,
              ),
              Icon(Icons.comment),
              SizedBox(
                width: 8.0,
              ),
              Icon(Icons.send),
            ],
          ),
          trailing: Icon(Icons.bookmark_border),
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            Text(
              '좋아요 ${test['likedUsers']?.length ?? 0}개',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
            ),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          children: <Widget>[
            SizedBox(
              width: 16.0,
            ),
            Text(
              test['email'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 8.0,
            ),
            Text(test['contents']),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),

        if (commentCount > 0)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentPage(widget.document),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        '댓글 $commentCount개 모두 보기',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Text(test['lastComment'] ?? ' '),
                ],
              ),
            ),
          ),
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: TextField(
                  controller: _commentController,
                  onSubmitted: (text) {
                    _writeComment(text);
                    _commentController.text = '';
                  },
                  decoration: InputDecoration(
                    hintText: '댓글 달기',
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }

  // 좋아요
  void _like() {
    var test = widget.document.data() as Map;
    // 기존 좋아요가 포함된 리스트를 복사
    final List likedUsers = List<String>.from(test['likedUsers'] ?? []);

    // 내가 좋아요 터치하면, 좋아요 터치한 이메일 리스트에, 내 이메일이 추가됨
    likedUsers.add(widget.user.email);
    
    // 업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    // firebase에 업데이트
    FirebaseFirestore.instance.collection('post')
      .doc(widget.document.id)
      .update(updateData);
  }

  // 좋아요 취소
  void _unlike() {
    var test = widget.document.data() as Map;
    // 기존 좋아요가 포함된 리스트를 복사
    final List likedUsers = List<String>.from(test['likedUsers'] ?? []);

    // 내가 좋아요 터치하면, 좋아요 터치한 이메일 리스트에, 내 이메일이 추가됨
    likedUsers.remove(widget.user.email);

    // 업데이트할 항목을 문서로 준비
    final updateData = {
      'likedUsers': likedUsers,
    };

    // firebase에 업데이트
    FirebaseFirestore.instance.collection('post')
        .doc(widget.document.id)
        .update(updateData);
  }

  // 댓글 작성
  void _writeComment(String text) {
    final data = {
      'writer': widget.user.email,
      'comment': text,
    };

    // 댓글 내용을 추가
    FirebaseFirestore.instance.collection('post')
      .doc(widget.document.id)
      .collection('comment')
      .add(data);

    // 댓글 갯수를 +1, 마지막 댓글인 lastComment update
    final updateData = {
      'lastComment': text,
      'commentCount': (widget.document['commentCount'] ?? 0) + 1,
    };

    FirebaseFirestore.instance.collection('post')
        .doc(widget.document.id)
        .update(updateData);
  }
}
