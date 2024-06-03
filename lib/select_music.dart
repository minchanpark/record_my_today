import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_data_api/youtube_data_api.dart';
import 'package:flutter/material.dart';

class SelectMusic extends StatefulWidget {
  const SelectMusic({super.key});

  @override
  State<SelectMusic> createState() => _SelectMusicState();
}

class _SelectMusicState extends State<SelectMusic> {
  final YoutubeDataApi youtubeDataApi = YoutubeDataApi();

  final searchController = TextEditingController();
  String query = '';

  List<dynamic>? contentList2;
  bool isLoading = false;
  FocusNode textfieldFocusNode = FocusNode();

  static String key = 'AIzaSyAp-1oVD2cFhwktdAB60solbLo1LpboTiA';
  YoutubeAPI ytApi = YoutubeAPI(key);
  List<YouTubeVideo> videoResult = [];

  void _search(String query) async {
    setState(() {
      isLoading = true;
    });
    try {
      List results = await youtubeDataApi.fetchSearchVideo(
          query, 'AIzaSyAp-1oVD2cFhwktdAB60solbLo1LpboTiA');

      setState(() {
        contentList2 = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
    videoResult = await ytApi.search(query);
  }

  Widget _buildSearchResultDetailBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (contentList2 == null || contentList2!.isEmpty) {
      return const Center(
        child: Text(
          "No results found.",
          style: TextStyle(fontFamily: 'Ribeye'),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: contentList2!.length,
        itemBuilder: (context, index) {
          final video = contentList2![index];
          return ListTile(
            leading: video.thumbnails != null && video.thumbnails!.isNotEmpty
                ? Image.network(video.thumbnails![0].url.toString())
                : const SizedBox.shrink(),
            title: Text(
              video.title ?? 'No title',
              style: const TextStyle(fontFamily: 'Ribeye'),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              print('${video.videoId}');
              Navigator.pop(context, {
                'recordTime': DateTime.now(),
                'youtubeImage':
                    video.thumbnails != null && video.thumbnails!.isNotEmpty
                        ? video.thumbnails![0].url.toString()
                        : '',
                'youtubeTitle': video.title ?? 'No title',
                'videoId': video.videoId,
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildTrendingMusicBody() {
    return Expanded(
      child: FutureBuilder(
        future: youtubeDataApi.fetchTrendingMusic(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            List contentList2 = snapshot.data;
            return ListView.builder(
              itemCount: contentList2.length,
              itemBuilder: (context, index) {
                final video = contentList2[index];

                return ListTile(
                  leading: Image.network(video.thumbnails![0].url.toString()),
                  title: Text(
                    video.title!,
                    style: const TextStyle(fontFamily: 'Ribeye'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.pop(context, {
                      'recordTime': DateTime.now(),
                      'youtubeImage': video.thumbnails![0].url.toString(),
                      'youtubeTitle': video.title!,
                      'videoId': video.videoId,
                    });
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No data"));
          }
        },
      ),
    );
  }

  Widget _buildSearchResultsBody() {
    return Expanded(
      child: FutureBuilder(
        future: youtubeDataApi.fetchSuggestions(query),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            List<String> suggestions = snapshot.data;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    suggestions[index],
                    style: const TextStyle(fontFamily: 'Ribeye'),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    setState(() {
                      searchController.text = suggestions[index];
                      query = suggestions[index];

                      _search(query);
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("No suggestions available"));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Select Music',
          style: TextStyle(
            fontFamily: 'Ribeye',
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: height * (36 / 852),
              child: TextField(
                cursorColor: Colors.black,
                focusNode: textfieldFocusNode,
                controller: searchController,
                decoration: InputDecoration(
                  fillColor: const Color.fromRGBO(255, 255, 255, 0.1),
                  filled: true,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.3),
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.3),
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(255, 255, 255, 0.3),
                      width: width * (1 / 320),
                    ),
                  ),
                  labelText: 'please search song title or "singer+title"',
                  labelStyle: TextStyle(
                    fontFamily: 'Ribeye',
                    color: Colors.black,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                      query = '';
                      setState(() {
                        contentList2 = null;
                      });
                      textfieldFocusNode.requestFocus();
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                onTap: () {
                  setState(() {
                    contentList2 = null;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    _search(value);
                  });
                },
              ),
            ),
            SizedBox(height: height * (20 / 852)),
            query.isNotEmpty && contentList2 != null
                ? _buildSearchResultDetailBody()
                : (query.isEmpty
                    ? _buildTrendingMusicBody()
                    : _buildSearchResultsBody()),
          ],
        ),
      ),
    );
  }
}
