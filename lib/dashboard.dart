import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:club/screens/club_posts_widget.dart';
import 'package:club/screens/task_screen.dart';
import 'package:flutter/material.dart';

import 'services/usermngmt.dart';

class DashboardPage extends StatefulWidget {
  final data;
  DashboardPage({this.data});
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  UserManagement userObj = new UserManagement();
  TextEditingController reminderTextController = new TextEditingController();
  TextEditingController contentController = new TextEditingController();
  TabController _tabController;
  int _currentIndex = 0;
  String userType = "";
  String userName = "";
  String collectionName = "";
  int numberOfClubs = 0;
  int numberOfStudents = 0;
  List clubs;
  List students;
  int indexOfScreen = 0;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void fetchUserInformation() async {
    students = await FirebaseFirestore.instance
        .collection('students')
        .get()
        .then((snapshot) {
      return snapshot.docs;
    });
    numberOfStudents = students.length;
    clubs = await FirebaseFirestore.instance
        .collection("clubs")
        .get()
        .then((snapshot) {
      return snapshot.docs;
    });
    numberOfClubs = clubs.length;

    for (int i = 0; i < students.length; i++) {
      if (students[i].exists) {
        if (students[i].data()["email"] == widget.data.email) {
          collectionName = "students";
        }
      }
    }
    for (int i = 0; i < clubs.length; i++) {
      if (clubs[i].exists) {
        if (clubs[i].data()["email"] == widget.data.email) {
          collectionName = "clubs";
        }
      }
    }

    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.data.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          userType = documentSnapshot.data()["type"];
          userName = documentSnapshot.data()["name"];
        });

        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });

    setState(() {});
  }

  _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  void addPost({
    String email,
    DateTime startDateTime,
    DateTime endDateTime,
    String subject,
    String content,
  }) {
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(email)
        .collection("posts")
        .add({
      "startDateTime": startDateTime,
      "endDateTime": endDateTime,
      "subject": subject,
      "content": content,
    });
  }

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fetchUserInformation();
    super.initState();
  }

  _handleTabSelection() {
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            // Tab index when user select it, it start from zero
            setState(() {
              indexOfScreen = index;
            });
          },
          tabs: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Tasks",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Feed",
                style: TextStyle(fontSize: 15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "Clubs",
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        title: ListTile(
          title: Text(
            "Scheduler",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          subtitle: Text(
            userName + " ( " + userType + " ) ",
            style: TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
                onTap: () {
                  userObj.signOut();
                },
                child: Icon(Icons.logout)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: TaskScreen(
              email: widget.data.email,
              collectionName: collectionName,
            ),
          ),
          Center(
            child: Text(
              "Add Tasks",
              style: TextStyle(fontSize: 40),
            ),
          ),
          Center(
            child: ClubPostsWidget(
              numberOfClubs: numberOfClubs,
              clubs: clubs,
              email: widget.data.email,
              collectionName: collectionName,
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20.0)), //this right here
                        child: Container(
                          height: (3 * MediaQuery.of(context).size.height) / 4,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListView(
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextFormField(
                                          controller: reminderTextController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: "Reminder Subject",
                                              hintText:
                                                  'What do you want to remember?'),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: TextFormField(
                                          maxLines: 8,
                                          controller: contentController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: "Reminder Content",
                                              hintText:
                                                  'What do you want to remember?'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    RaisedButton(
                                      // Refer step 3

                                      child: Text(
                                        'Select start date',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      color: Colors.blue,
                                      onPressed: () {
                                        _selectStartDate(context);
                                      },
                                    ),
                                    RaisedButton(
                                      // Refer step 3
                                      child: Text(
                                        'Select end date',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      color: Colors.blue,
                                      onPressed: () {
                                        _selectEndDate(context);
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Close",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.blue,
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        addPost(
                                            email: widget.data.email,
                                            startDateTime: startDate,
                                            endDateTime: endDate,
                                            subject:
                                                reminderTextController.text,
                                            content: contentController.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Save",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: Colors.blue,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            )
          : Container(),
    );
  }
}
