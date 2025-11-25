import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const PappapApp());

class PappapApp extends StatefulWidget {
  const PappapApp({super.key});
  @override State<PappapApp> createState() => _PappapAppState();
}

class _PappapAppState extends State<PappapApp> {
  String response = "Đang kết nối Genesis Node...";
  final ctrl = TextEditingController();

  Future<void> send(String text) async {
    try {
      final res = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/prompt"),
        headers: {"Content-Type":"application/json"},
        body: json.encode({"prompt": text}),
      );
      final data = json.decode(res.body);
      setState(() => response = data["response"] ?? "Lỗi kết nối");
    } catch (e) {
      setState(() => response = "Node chưa chạy");
    }
  }

  @override Widget build(BuildContext context) => MaterialApp(
    title: "PAPPAP AI CHAIN SNN",
    home: Scaffold(
      appBar: AppBar(title: const Text("choithuti@MAPLE0276 – Genesis Node")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(response, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          TextField(controller: ctrl, decoration: const InputDecoration(labelText: "Nhập tin nhắn")),
          ElevatedButton(onPressed: () => send(ctrl.text), child: const Text("Gửi tới Genesis Node")),
        ]),
      ),
    ),
  );
}
