//import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_page.dart';
import 'detail_post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatelessWidget {
  final User user;

  SearchPage(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Instagram Clone',
          style: GoogleFonts.pacifico(),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'Instagram Clone',
        style: GoogleFonts.pacifico(),
      ),
    );
  }

  Widget _buildBody(context) {
    print('search_page created');
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('post').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(),);
          }

          var items = snapshot.data.docs ?? [];

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                mainAxisSpacing: 1.0,
                crossAxisSpacing: 1.0),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildListItem(context, items[index]);
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.create),
        onPressed: () {
          print('눌림');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => CreatePage(user)));
        },
      ),
    );
  }

  Widget _buildListItem(context, DocumentSnapshot document) {
    return Hero(
      tag: document.id,
      child: Material(
        child: InkWell(
          onTap: () {
            print('클릭!!');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailPostPage(document, user))
,        );
          },
          child: Image.network(
            document['photoUrl'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
