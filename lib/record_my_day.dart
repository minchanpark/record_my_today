import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    DateTime select_time = selectedDay;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: height * (150 / 852)),
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'record my day',
              style: TextStyle(
                fontFamily: 'Ribeye',
                fontSize: width * (20 / 393),
              ),
            ),
            SizedBox(height: height * (56 / 852)),
            //달력 넣기
            TableCalendar(
              //calendarStyle: CalendarStyle(),
              firstDay: DateTime.utc(2021, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: focusedDay,
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                // 선택된 날짜의 상태를 갱신합니다.
                setState(() {
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (DateTime day) {
                // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (currentUser != null) {
                      await checkDataAndNavigate(
                          context, select_time, currentUser!.uid);
                    } else {
                      // Handle user not logged in
                    }
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
