import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

Future<List<Map<String, dynamic>>> fetchPosts() async {
  var response = await http.get(
    Uri.parse('https://discuss.flarum.org/api/posts'),
  );

  if (response.statusCode == 200) {
    //Parse the JSON response
    Map<String, dynamic> data = json.decode(response.body);
    //Exract the 'posts' data from the response
    List posts = data['data'];

    return List<Map<String, dynamic>>.from(posts);
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
          body: Center(
        child: NetworkData(),
      )),
    );
  }
}

class NetworkData extends StatelessWidget {
  const NetworkData({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              var postContent = post['attributes']['contentHtml'];

              return ListTile(
                title: Text('${postContent}'),
              );
            },
          );
        } else {
          return const Text('No data available');
        }
      },
    );
  }
}
