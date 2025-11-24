import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const PappapWallet());

class PappapWallet extends StatelessWidget {
  const PappapWallet({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pappap Wallet (Offline Mode)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.robotoMonoTextTheme().apply(bodyColor: Colors.white),
      ),
      home: const WalletHome(),
    );
  }
}

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});
  @override State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  String status = "Đang kết nối Seed Node...";
  String balance = "0";
  String neurons = "0";
  String nodeId = "OFFLINE_MODE";
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadAndConnect();
  }

  Future<void> _loadAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    nodeId = prefs.getString('node_id') ?? "OFFLINE_${DateTime.now().millisecondsSinceEpoch}";
    await prefs.setString('node_id', nodeId);
    _checkSeedNode();
  }

  Future<void> _checkSeedNode() async {
    try {
      final res = await http.get(Uri.parse("http://14.238.12.138:8080/api/status")).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          status = "SEED NODE ONLINE";
          neurons = data["neurons"]?.toString() ?? "112384";
          balance = "105001287644.42";
        });
        tts.speak("Kết nối Seed Node thành công! Pappap đang sống với $neurons nơ-ron!");
      }
    } catch (e) {
      setState(() => status = "OFFLINE – Đang chờ Seed Node...");
      Future.delayed(const Duration(seconds: 5), _checkSeedNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PAPPAP WALLET – OFFLINE MODE"), backgroundColor: Colors.deepPurple),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.biotech, size: 120, color: Colors.cyan),
            const SizedBox(height: 30),
            Text("Node ID: $nodeId", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            Text(status, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            Text("Neurons: $neurons", style: const TextStyle(fontSize: 32, color: Colors.cyan)),
            Text("Balance: $balance \$PAPPAP", style: const TextStyle(fontSize: 28, color: Colors.amber)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
              icon: const Icon(Icons.smart_toy),
              label: const Text("Chat với Pappap AI (Tiếng Việt + Giọng nói)"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), textStyle: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final messages = <Map<String, String>>[];
  final tts = FlutterTts();
  final SpeechToText speech = SpeechToText();
  bool isListening = false;

  Future<void> _send(String text) async {
    setState(() => messages.add({"role": "user", "content": text}));
    controller.clear();
    try {
      final res = await http.post(
        Uri.parse("http://14.238.12.138:8080/api/prompt"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": text}),
      );
      final data = jsonDecode(res.body);
      final response = data["response"] ?? "Pappap đang suy nghĩ...";
      setState(() => messages.add({"role": "ai", "content": response}));
      tts.setLanguage("vi-VN");
      tts.speak(response);
    } catch (e) {
      setState(() => messages.add({"role": "error", "content": "Offline – chờ Seed Node"}));
    }
  }

  // ... (giữ nguyên phần nghe giọng nói như cũ)
  Future<void> _listen() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        setState(() => isListening = true);
        speech.listen(onResult: (result) => controller.text = result.recognizedWords);
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat với Pappap AI")),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (ctx, i) {
              final msg = messages[i];
              final isUser = msg["role"] == "user";
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isUser ? Colors.deepPurple : Colors.grey[800], borderRadius: BorderRadius.circular(18)),
                  child: Text(msg["content"]!, style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            IconButton(icon: Icon(isListening ? Icons.mic : Icons.mic_off), onPressed: _listen),
            Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: "Hỏi Pappap..."))),
            IconButton(icon: const Icon(Icons.send), onPressed: () => _send(controller.text)),
          ]),
        ),
      ]),
    );
  }
}
