import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  final String email;
  final String collectionName;
  TaskScreen({this.email, this.collectionName});
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<String> emails = [];
  List postMap = [];
  List posts = [];
  List<Post> postCollection = [];

  void fetchSubsriptionEmails(List<Post> postCollection) async {
    var subscribedEmails = await FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.email)
        .collection("subscriptions")
        .get()
        .then((snapshot) {
      return snapshot.docs;
    });

    for (int i = 0; i < subscribedEmails.length; i++) {
      emails.add(subscribedEmails[i].data()["subscribedEmail"]);
    }
    fetchSubscriptionPosts();

    setState(() {});
  }

  Future fetchSubscriptionPosts() async {
    for (int i = 0; i < emails.length; i++) {
      await FirebaseFirestore.instance
          .collection("clubs")
          .doc(emails[i])
          .collection("posts")
          .get()
          .then((snapshot) {
        postMap.add(
          snapshot.docs.map(
            (item) {
              return {emails[i]: item.data()};
            },
          ).toList(),
        );
        return snapshot.docs;
      });
    }
    for (int i = 0; i < postMap.length; i++) {
      for (int j = 0; j < postMap[i].length; j++) {
        postMap[i][j].forEach(
          (k, v) => {
            postCollection.add(Post(
              content: v["content"],
              subject: v["subject"],
              startDate: v["startDateTime"].toDate(),
              endDate: v["endDateTime"].toDate(),
            )),
          },
        );
        print(postMap[i][j]);
      }
    }
    print(postCollection);
  }

  @override
  void initState() {
    fetchSubsriptionEmails(postCollection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: postCollection.length,
      itemBuilder: (BuildContext context, int index) {
        return postCollection[index].PostTile();
      },
    );
  }
}

class Post {
  String content;
  String subject;
  DateTime startDate;
  DateTime endDate;

  Post({this.content, this.endDate, this.startDate, this.subject});

  Widget PostTile() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.notifications_active,
              color: Colors.red,
              size: 30,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(startDate.toString() + "   " + endDate.toString()),
          ),
        ),
      ),
    );
  }
}
