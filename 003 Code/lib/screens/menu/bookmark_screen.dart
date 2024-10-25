import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../tea/PostDetailScreen.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Map<dynamic, dynamic>> bookmarksList = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _listenForPostDeletions();
  }

  void _loadBookmarks() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference _bookmarkRef = FirebaseDatabase.instance
          .reference()
          .child('bookmarks')
          .child(user.uid);
      _bookmarkRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        final List<Map<dynamic, dynamic>> loadedBookmarks = [];
        if (data != null) {
          data.forEach((key, value) {
            loadedBookmarks.add(value as Map<dynamic, dynamic>);
          });
        }
        setState(() {
          bookmarksList = loadedBookmarks;
        });
      });
    }
  }

  void _listenForPostDeletions() {
    DatabaseReference _postsRef = FirebaseDatabase.instance.reference().child('posts');
    _postsRef.onChildRemoved.listen((event) {
      final deletedPostId = event.snapshot.key;
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference _bookmarkRef = FirebaseDatabase.instance
            .reference()
            .child('bookmarks')
            .child(user.uid);
        _bookmarkRef.onValue.listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            data.forEach((key, value) {
              if (value['postId'] == deletedPostId) {
                _bookmarkRef.child(key).remove();
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '북마크',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: bookmarksList.isEmpty
          ? Center(child: Text('북마크된 게시물이 없습니다.'))
          : GridView.builder(
        padding: EdgeInsets.all(22.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1 / 1.3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 20,
        ),
        itemCount: bookmarksList.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarksList[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: bookmark),
                  ),
                );
              },

                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                if (bookmark['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
                  topRight: Radius.circular(10), // 이미지 위 모서리 둥글게 설정
               ),
                child: AspectRatio(
                  aspectRatio: 15.5 / 13.0,
                  child: Image.network(
                    bookmark['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        bookmark['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),

                    SizedBox(height: 2),

                    AutoSizeText(
                      bookmark['herbType'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF49454F),
                      ),
                      maxLines: 1,
                    ),
                    ],
                  ),
                ),
                    ],
                ),
            ),
          );
        },
      ),
    );
  }
}