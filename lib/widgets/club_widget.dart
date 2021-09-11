import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

class ClubWidget extends StatefulWidget {
  bool isSubscribed;
  final String clubName;
  final String subClubName;
  final String collectionName;
  final String emailToSubscribe;
  final String email;
  ClubWidget(
      {this.isSubscribed,
      this.clubName,
      this.subClubName,
      this.collectionName,
      this.email,
      this.emailToSubscribe});
  @override
  _ClubWidgetState createState() => _ClubWidgetState();
}

class _ClubWidgetState extends State<ClubWidget> {
  void addSubscriptions({
    String email,
    String emailToSubscribe,
  }) {
    if (widget.isSubscribed == true) {
      FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(email)
          .collection("subscriptions")
          .doc(emailToSubscribe)
          .set({
        "subscribedEmail": emailToSubscribe,
      });
    } else {
      FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(email)
          .collection("subscriptions")
          .doc(emailToSubscribe)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          trailing: GestureDetector(
            onTap: () {
              setState(() {
                widget.isSubscribed = !widget.isSubscribed;
                addSubscriptions(
                    email: widget.email,
                    emailToSubscribe: widget.emailToSubscribe);
              });
            },
            child: Icon(
              Icons.notifications,
              color: widget.isSubscribed ? Colors.blue : Colors.grey,
              size: 30,
            ),
          ),
          title: Text(
            widget.clubName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.subClubName,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}
