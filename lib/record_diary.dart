import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'select_music.dart';
import 'package:intl/intl.dart';

class RecordDiary extends StatefulWidget {
  final DateTime recordTime;
  final String youtubeImage;
  final String youtubeTitle;
  final String videoId;

  const RecordDiary({
    super.key,
    required this.recordTime,
    required this.youtubeImage,
    required this.youtubeTitle,
    required this.videoId,
  });

  @override
  State<RecordDiary> createState() => _RecordDiaryState();
}

class _RecordDiaryState extends State<RecordDiary> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? result;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot document = await firestore
          .collection(currentUser!.uid)
          .doc(widget.recordTime.toString())
          .get();

      if (document.exists) {
        Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            titleController.text = data['text'] ?? '';
            contentController.text = data['content'] ?? '';
            result = {
              'youtubeImage': data['youtubeImage'] ?? widget.youtubeImage,
              'youtubeTitle': data['youtubeTitle'] ?? widget.youtubeTitle,
              'videoId': data['videoId'] ?? widget.videoId,
            };
          });
        }
      }
    } catch (e) {
      print('Error loading data from Firestore: $e');
    }
  }

  Future<void> saveToFirestore() async {
    if (currentUser == null) {
      print('No user logged in');
      return;
    }

    try {
      Map<String, dynamic> dataToSave = {
        'text': titleController.text,
        'content': contentController.text,
        'youtubeImage': result?['youtubeImage'] ?? 'nullImage',
        'youtubeTitle': result?['youtubeTitle'] ?? 'nullTitle',
        'videoId': result?['videoId'] ?? widget.videoId,
        'timestamp': widget.recordTime,
      };

      await firestore
          .collection(currentUser!.uid)
          .doc(widget.recordTime.toString())
          .set(dataToSave);

      Navigator.pop(context, {'videoId': widget.videoId});
      print('Record saved successfully');
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
  }

  Future<void> pushNextPage() async {
    final selectedMusic = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectMusic()),
    );

    if (selectedMusic != null) {
      setState(() {
        result = selectedMusic;
      });
    }
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    double heightFactor = 54 / 852,
    TextAlign textAlign = TextAlign.center,
    TextAlignVertical textAlignVertical = TextAlignVertical.center,
  }) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      width: width * (340 / 393),
      height: height * heightFactor,
      color: const Color.fromRGBO(217, 217, 217, 0.3),
      child: TextFormField(
        textAlign: textAlign,
        textAlignVertical: textAlignVertical,
        controller: controller,
        cursorColor: Colors.black,
        maxLines: heightFactor > 54 / 852 ? null : 1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
              top: heightFactor > 54 / 852 ? height * (190 / 852) : 0),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color.fromRGBO(0, 0, 0, 0.6),
            fontFamily: 'Ribeye',
            fontSize: width * (20 / 393),
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy. MM. dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'today’s feeling?',
          style: TextStyle(
            fontFamily: 'Ribeye',
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            children: [
              const Divider(),
              Text(
                formatDate(widget.recordTime),
                style: TextStyle(
                  fontFamily: 'Ribeye',
                  fontSize: width * (18 / 393),
                ),
              ),
              SizedBox(height: height * (7 / 852)),
              _buildTextField(hintText: 'title', controller: titleController),
              SizedBox(height: height * (25 / 852)),
              _buildTextField(
                hintText: 'record your today',
                controller: contentController,
                heightFactor: 440 / 852,
              ),
              SizedBox(height: height * (15 / 852)),
              if (result == null || result!['youtubeImage'] == 'nullImage')
                ElevatedButton(
                  onPressed: pushNextPage,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFD9D9D9),
                  ),
                  child: Text(
                    'record as music',
                    style: TextStyle(
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                      fontFamily: 'Ribeye',
                      fontSize: width * (15 / 393),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    SizedBox(width: width * (10 / 320)),
                    Expanded(
                      child: ListTile(
                        leading: Image.network(result!['youtubeImage']),
                        title: Text(
                          result!['youtubeTitle'],
                          style: TextStyle(
                            color: const Color.fromRGBO(0, 0, 0, 1),
                            fontFamily: 'Ribeye',
                            fontSize: width * (15 / 393),
                          ),
                        ),
                        onTap: pushNextPage,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: height * (20 / 852)),
              Row(
                children: [
                  const Expanded(child: Text('')),
                  ElevatedButton(
                    onPressed: saveToFirestore,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFD9D9D9),
                    ),
                    child: Text(
                      'store',
                      style: TextStyle(
                        color: const Color.fromRGBO(0, 0, 0, 0.7),
                        fontFamily: 'Ribeye',
                        fontSize: width * (15 / 393),
                      ),
                    ),
                  ),
                  SizedBox(width: width * (20 / 320)),
                ],
              ),
              SizedBox(height: height * (20 / 852)),
            ],
          ),
        ),
      ),
    );
  }
}
