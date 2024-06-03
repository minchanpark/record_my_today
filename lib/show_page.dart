import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moapp_project/record_diary.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  void youtubePlayerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 300,
            height: 200,
            color: Colors.white,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://www.youtube.com/embed/${widget.videoId}"),
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
          )
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
                        SizedBox(height: height * (45 / 852)),
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
