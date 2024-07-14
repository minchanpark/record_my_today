import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';

import 'record_diary.dart';
import 'show_page.dart';

class RecordMyDay extends StatefulWidget {
  const RecordMyDay({super.key});

  @override
  State<RecordMyDay> createState() => _RecordMyDayState();
}

class _RecordMyDayState extends State<RecordMyDay> {
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
  }

  Future<void> signOutGoogle() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> signOutEmailPassword() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    DateTime select_time = selectedDay;

    Widget logOutButton() {
      return IconButton(
        onPressed: () {
          Navigator.pop(context);
          signOutEmailPassword();
          signOutGoogle();
        },
        icon: Icon(
          Icons.logout,
          color: Colors.black,
          size: width * (27 / 393),
        ),
      );
    }

    Widget profileButton() {
      return IconButton(
        onPressed: () {},
        icon: Icon(
          Icons.person_outline,
          color: Colors.black,
          size: width * (27 / 393),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: height * (70 / 852)),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: width * (95 / 393)),
                Text(
                  'record my day',
                  style: TextStyle(
                    fontFamily: 'Ribeye',
                    fontSize: width * (25 / 393),
                  ),
                ),
                SizedBox(width: width * (45 / 393)),
                logOutButton(),
              ],
            ),
            SizedBox(height: height * (90 / 852)),
            TableCalendar(
              firstDay: DateTime.utc(2021, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              calendarStyle: const CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
                selectedDecoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDay, day);
              },
            ),
            SizedBox(height: height * (80 / 852)),
            Row(
              children: [
                const Expanded(child: Text('')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color.fromRGBO(73, 69, 79, 0.25),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (currentUser != null) {
                      await checkDataAndNavigate(
                          context, select_time, currentUser!.uid);
                    } else {}
                  },
                  child: const Icon(Icons.create),
                ),
                SizedBox(width: width * (30 / 393)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkDataAndNavigate(
      BuildContext context, DateTime selectTime, String uid) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(uid)
        .doc(selectedDay.toString())
        .get();

    if (snapshot.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ShowDiary(
                  recordTime: selectTime,
                  youtubeImage: '',
                  youtubeTitle: '',
                  videoId: '',
                )),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordDiary(
            recordTime: selectTime,
            youtubeImage: '',
            youtubeTitle: '',
            videoId: '',
          ),
        ),
      );
    }
  }
}
