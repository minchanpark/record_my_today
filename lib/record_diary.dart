import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'select_music.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  String _response = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _sendPrompt() async {
    final String? apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null) {
      setState(() {
        _response = 'Error: API key not found';
      });
      return;
    }

    const String apiUrl = 'https://api.openai.com/v1/chat/completions';
    final String prompt =
        '"${contentController.text}"라는 글에 맞는 노래를 추천해주고, “노래 제목 by 가수” 이런 식으로 대답만 해줘';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _response = jsonResponse['choices'][0]['message']['content'] ??
              'No recommended song found.';
        });
      } else {
        setState(() {
          _response =
              'Error: ${response.reasonPhrase}, Details: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
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
              top: heightFactor > 54 / 852 ? height * (170 / 852) : 0),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color.fromRGBO(0, 0, 0, 0.3),
            fontFamily: 'Ribeye',
            fontSize: width * (20 / 393),
          ),
        ),
      ),
    );
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
              SizedBox(height: height * (20 / 852)),
              _buildTextField(hintText: 'title', controller: titleController),
              SizedBox(height: height * (25 / 852)),
              _buildTextField(
                  hintText: 'record your today',
                  controller: contentController,
                  heightFactor: 384 / 852),
              SizedBox(height: height * (10 / 852)),
              ElevatedButton(
                onPressed: _sendPrompt,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFD9D9D9),
                ),
                child: Text(
                  'Recommended Song',
                  style: TextStyle(
                    color: const Color.fromRGBO(0, 0, 0, 0.59),
                    fontFamily: 'Ribeye',
                    fontSize: width * (15 / 393),
                  ),
                ),
              ),
              if (_response.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _response,
                    style: TextStyle(
                      fontFamily: 'Ribeye',
                      fontSize: width * (15 / 393),
                    ),
                  ),
                ),
              SizedBox(height: height * (10 / 852)),
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
                      color: const Color.fromRGBO(0, 0, 0, 0.59),
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
              SizedBox(height: height * (10 / 852)),
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
                        color: const Color.fromRGBO(0, 0, 0, 0.59),
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
