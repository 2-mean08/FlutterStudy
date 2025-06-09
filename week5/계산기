import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final items = List.generate(100, (i) => i).toList();

  MyHomePage({super.key});

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: GestureDetector(
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color ?? Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          height: 60,
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("계산기"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 디스플레이 영역
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: const Text(
              "0",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          // 버튼 영역
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton("MC"),
                    _buildButton("MR"),
                    _buildButton("M+"),
                    _buildButton("M-"),
                    _buildButton("MS"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("CE"),
                    _buildButton("C"),
                    _buildButton("⌫"),
                    _buildButton("÷"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("½"),
                    _buildButton("x²"),
                    _buildButton("√x"),
                    _buildButton("+"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("-"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("*"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("+"),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("+/-"),
                    _buildButton("0"),
                    _buildButton("."),
                    _buildButton("=", color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
