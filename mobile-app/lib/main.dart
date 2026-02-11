import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GKE Demo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'GKE Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = 'Press the button to fetch data';
  // Replace with your LoadBalancer IP later. 
  // For Android emulator, use 10.0.2.2 to access host localhost.
  // But for GKE, this will be an external IP.
  final String _backendUrl = 'http://136.111.200.138'; 

  Future<void> _fetchData() async {
    setState(() {
      _message = 'Loading...';
    });

    try {
      final response = await http.get(Uri.parse('$_backendUrl/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _message = 'Response: ${data['Hello']}';
        });
      } else {
        setState(() {
          _message = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Backend Response:',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _message,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        tooltip: 'Fetch Data',
        child: const Icon(Icons.download),
      ),
    );
  }
}
