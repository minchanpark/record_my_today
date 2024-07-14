import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moapp_project/record_diary.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

class ShowDiary extends StatefulWidget {
  final DateTime recordTime;
  final String youtubeImage;
  final String youtubeTitle;
  final String videoId;

  const ShowDiary({
    super.key,
    required this.recordTime,
    required this.youtubeImage,
    required this.youtubeTitle,
    required this.videoId,
  });

  @override
  State<ShowDiary> createState() => _ShowDiaryState();
}

class _ShowDiaryState extends State<ShowDiary> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late InAppWebViewController webViewController;
  bool _isPlayerReady = false;

  @override
  void dispose() {
    super.dispose();
  }

  void updateVideoId(String videoId) {
    if (_isPlayerReady) {
      webViewController.loadUrl(
        urlRequest: URLRequest(
          url: WebUri("https://www.youtube.com/embed/$videoId"),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy. MM. dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    void deleteAlertDialog() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
              child: Padding(
            padding: EdgeInsets.only(top: height * (20 / 852)),
            child: const Text(
              'Do you want to delete this note?',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Ribeye',
                color: Colors.black,
              ),
            ),
          )),
          elevation: 0,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Ribeye',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                print('delete successful!!');
                firestore
                    .collection(currentUser!.uid)
                    .doc(widget.recordTime.toString())
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Ribeye',
                ),
              ),
            ),
          ],
        ),
      );
    }

    void youtubePlayerDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              width: width * (500 / 320),
              height: height * (400 / 852),
              color: Colors.white,
              child: InAppWebView(
                initialUrlRequest: URLRequest(
                  url:
                      WebUri("https://www.youtube.com/embed/${widget.videoId}"),
                ),
                initialSettings: InAppWebViewSettings(
                  allowsInlineMediaPlayback: true,
                  mediaPlaybackRequiresUserGesture: true,
                  userAgent:
                      "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  setState(() {
                    _isPlayerReady = true;
                  });
                },
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Padding(
          padding: const EdgeInsets.only(left: 55),
          child: Text(
            'today’s feeling?',
            style: TextStyle(
              fontFamily: 'Ribeye',
              overflow: TextOverflow.visible,
              fontSize: width * (18 / 393),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordDiary(
                    recordTime: widget.recordTime,
                    youtubeImage: widget.youtubeImage,
                    youtubeTitle: widget.youtubeTitle,
                    videoId: '',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.create,
              color: Colors.black,
            ),
          ),
          IconButton(
              onPressed: () {
                deleteAlertDialog();
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<DocumentSnapshot>(
              stream: firestore
                  .collection(currentUser!.uid)
                  .doc(widget.recordTime.toString())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                      child: Text('No data available for this date.'));
                }

                Map<String, dynamic>? data =
                    snapshot.data!.data() as Map<String, dynamic>?;
                String title = data?['text'] ?? '';
                String content = data?['content'] ?? '';
                String youtubeImage =
                    data?['youtubeImage'] ?? widget.youtubeImage;
                String youtubeTitle =
                    data?['youtubeTitle'] ?? widget.youtubeTitle;
                String videoId = data?['videoId'] ?? widget.videoId;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_isPlayerReady && videoId != widget.videoId) {
                    updateVideoId(videoId);
                  }
                });

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: keyboardHeight),
                    child: Column(
                      children: [
                        const Divider(),
                        SizedBox(height: height * (15 / 852)),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: width * (20 / 393),
                          ),
                        ),
                        const Divider(
                          endIndent: 25,
                          indent: 25,
                        ),
                        SizedBox(height: height * (10 / 852)),
                        SizedBox(
                          width: width * (340 / 393),
                          height: height * (414 / 852),
                          child: Center(
                            child: Text(
                              content,
                              style: TextStyle(
                                fontSize: width * (20 / 393),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * (50 / 852)),
                        (youtubeImage == 'nullImage')
                            ? const SizedBox()
                            : Row(
                                children: [
                                  SizedBox(width: width * (10 / 320)),
                                  Expanded(
                                    child: ListTile(
                                      leading: Image.network(youtubeImage),
                                      title: Text(
                                        youtubeTitle,
                                        style: TextStyle(
                                          color:
                                              const Color.fromRGBO(0, 0, 0, 1),
                                          fontFamily: 'Ribeye',
                                          fontSize: width * (15 / 393),
                                        ),
                                      ),
                                      onTap: youtubePlayerDialog,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
