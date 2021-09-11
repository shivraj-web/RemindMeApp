import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Scheduler'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                  padding: EdgeInsets.all(12),
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Enter your Email",
                      labelText: "Email",
                    ),
                    controller: emailController,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(12),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Enter your Password",
                      labelText: "Password",
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () async {
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text);
                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      }
                    },
                    elevation: 5.0,
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text('Login'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
