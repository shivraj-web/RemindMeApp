import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../dashboard.dart';

class UserManagement {
  BehaviorSubject currentUser = BehaviorSubject<String>();

  Widget handleAuth() {
    return new StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          currentUser.add(snapshot.data.uid);
          return DashboardPage(
            data: snapshot.data,
          );
        }
        return LoginPage();
      },
    );
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }
}
