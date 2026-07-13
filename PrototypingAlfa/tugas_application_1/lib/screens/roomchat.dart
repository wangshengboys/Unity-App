import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config.dart'; // Sesuaikan lokasi Config Anda
import 'bubblechat.dart'; // Sesuaikan lokasi BubbleChat Anda

class RoomChat extends StatefulWidget {
  final String conversationId; // ID Room
  final int currentUserId; // ID Anda sendiri
  final String roomName;
  final String opponentName;
  final String opponentAvatar;

  const RoomChat({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.roomName,
    required this.opponentName,
    required this.opponentAvatar,
  });

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  IO.Socket? socket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessageHistory();
    _connectSocket();
  }

  @override
  void dispose() {
    if (socket != null) {
      // Tinggalkan room di backend sebelum menutup halaman
      socket!.emit('leave_conversation', {'conversation_id': widget.conversationId});
      socket!.disconnect();
    }
    _messageController.dispose();
    super.dispose();
  }

  // --- 1. AMBIL RIWAYAT PESAN DARI DATABASE ---
  Future<void> _fetchMessageHistory() async {
    try {
      final url = Uri.parse("${Config.baseUrl}/chat/get_messages?conversation_id=${widget.conversationId}");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List rawMessages = data['data'];
          setState(() {
            _messages = rawMessages
                .map(
                  (msg) => {
                    "id": msg['id'],
                    "text": msg['content'],
                    "time": msg['created_at'].toString().substring(11, 16), // Ambil HH:MM saja
                    "isMe": msg['sender_id'] == widget.currentUserId,
                  },
                )
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetch history: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. KONEKSI KE SOCKET.IO ---
  void _connectSocket() {
    // Ambil host utama (tanpa /api jika ada di baseUrl Anda)
    // Misal: http://192.168.1.5:5000
    String socketUrl = Config.baseUrl.replaceAll('/api', '');

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint('Connected to Socket.IO');
      // Masuk ke room khusus berdasarkan conversationId
      socket!.emit('join_conversation', {'conversation_id': widget.conversationId});
    });

    // Mendengarkan pesan masuk
    socket!.on('receive_message', (data) {
      if (data['conversation_id'] == widget.conversationId) {
        setState(() {
          _messages.add({
            "id": data['id'],
            "text": data['content'],
            "time": "Now",
            "isMe": data['sender_id'] == widget.currentUserId,
          });
        });

        // Membalas ke backend bahwa pesan sukses diterima
        // agar backend segera menghapus pesan transit tersebut (fitur E2EE)
        socket!.emit('message_delivered', {
          'message_id': data['id'],
          'message_type': data['message_type'],
          'content': data['content'],
        });
      }
    });
  }

  // --- 3. KIRIM PESAN ---
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Generate ID unik sementara pakai timestamp
    final String msgId = "msg_${DateTime.now().millisecondsSinceEpoch}";

    final payload = {
      "id": msgId,
      "conversation_id": widget.conversationId,
      "sender_id": widget.currentUserId,
      "message_type": "text",
      "content": text,
    };

    // Tembak ke server
    socket!.emit('send_message', payload);

    // Langsung render di layar sendiri tanpa menunggu respon dari server
    setState(() {
      _messages.add({"id": msgId, "text": text, "time": "Now", "isMe": true});
    });

    // Kosongkan kolom input
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.grey.shade200,
        leadingWidth: 70.w,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 60.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 50.w,
              backgroundImage: NetworkImage(widget.opponentAvatar),
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(width: 25.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.opponentName,
                    style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    widget.roomName,
                    style: TextStyle(fontSize: 30.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: ChatBackgroundPattern())),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return BubbleChat(message: msg['text'], time: msg['time'], isMe: msg['isMe']);
                        },
                      ),
              ],
            ),
          ),
          _buildInputChat(),
        ],
      ),
    );
  }

  Widget _buildInputChat() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(50.r)),
                child: Row(
                  children: [
                    Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 60.sp),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 35.sp, color: Colors.grey),
                        ),
                        style: TextStyle(fontSize: 35.sp),
                        maxLines: null,
                      ),
                    ),
                    Icon(Icons.attach_file, color: Colors.grey, size: 60.sp),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Container(
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: IconButton(
                icon: Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Icon(Icons.send, color: Colors.white, size: 50.sp),
                ),
                onPressed: _sendMessage, // Eksekusi fungsi kirim pesan
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CustomPainter untuk pola background tetap sama
class ChatBackgroundPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
