import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package'), actions: []), // AppBar
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: MaterialButton(
              color: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                var response = await get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
                print(response.body);
              },
              child: Text("Show Dialog"),
            ), // MaterialButton
          ), // Container
        ],
      ), // ListView
    ); // Scaffold;
  }
}
