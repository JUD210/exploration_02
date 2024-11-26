import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp()); // Entry point of the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NewsSummarizerPage(), // Set the main page
    );
  }
}

class NewsSummarizerPage extends StatefulWidget {
  const NewsSummarizerPage({super.key});

  @override
  NewsSummarizerPageState createState() =>
      NewsSummarizerPageState(); // Create State for StatefulWidget
}

class NewsSummarizerPageState extends State<NewsSummarizerPage> {
  String result = ""; // Variable to store the summary result
  final TextEditingController urlController =
      TextEditingController(); // Controller for URL input field
  final TextEditingController textController =
      TextEditingController(); // Controller for text input field
  final String defaultUrl =
      "http://127.0.0.1:12530"; // Default URL, replace with actual server address

  @override
  void initState() {
    super.initState();

    if (urlController.text.isEmpty) {
      urlController.text = defaultUrl;
    }
  }

  // Function to send text to the server and fetch the summary
  Future<void> fetchSummary() async {
    if (textController.text.isEmpty) {
      setState(() {
        result = "먼저 텍스트를 입력해주세요.";
      });
      return;
    }

    try {
      final String enteredUrl = urlController.text;
      final Uri uri =
          Uri.parse("$enteredUrl/predict"); // Adjust the endpoint as needed

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': '69420', // If necessary
        },
        body: jsonEncode({'text': textController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          result = data['summary'] ?? "요약 결과가 없습니다.";
        });
      } else {
        setState(() {
          result = "데이터를 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "오류 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("뉴스 요약기"), // Set the title of the app
        ),
        body: Center(
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(16.0), // Add some padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: textController, // Text input field
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: "텍스트 입력",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: urlController, // URL input field
                  decoration: const InputDecoration(
                    labelText: "서버 URL 입력",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchSummary,
                  child: const Text("요약 실행"),
                ),
                const SizedBox(height: 40),
                Text(
                  result,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )),
        ));
  }
}
