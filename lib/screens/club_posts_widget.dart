import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/widgets/club_widget.dart';
import "package:flutter/material.dart";

class ClubPostsWidget extends StatefulWidget {
  ClubPostsWidget(
      {this.numberOfClubs, this.clubs, this.email, this.collectionName});
  final int numberOfClubs;
  final List clubs;
  final String email;
  final String collectionName;
  @override
  _ClubPostsWidgetState createState() => _ClubPostsWidgetState();
}

class _ClubPostsWidgetState extends State<ClubPostsWidget> {
  List<String> emails = [];
  Map<String, bool> subscriptions = {};
  void fetchSubscriptions() async {
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
    setState(() {});
  }

  bool checkSubscription(String email) {
    if (emails.contains(email)) {
      subscriptions.addAll({email: true});
    } else {
      subscriptions.addAll({email: false});
    }
    print(subscriptions.toString() + email);
    print(emails);
    return emails.length == 0 ? false : subscriptions[email];
  }

  @override
  void initState() {
    fetchSubscriptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.numberOfClubs,
      itemBuilder: (BuildContext context, int index) {
        if (widget.clubs[index].data()["name"] != null) {
          return ClubWidget(
            isSubscribed:
                checkSubscription(widget.clubs[index].data()["email"]),
            clubName: widget.clubs[index].data()["name"],
            subClubName: widget.clubs[index].data()["email"],
            email: widget.email,
            collectionName: widget.collectionName,
            emailToSubscribe: widget.clubs[index].data()["email"],
          );
        } else if (widget.numberOfClubs <= 0) {
          return Container(
            child: Text("No Clubs here"),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
