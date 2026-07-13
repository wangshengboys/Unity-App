import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Pastikan path import BubbleChat ini sesuai dengan lokasi file Anda
import 'bubblechat.dart';

class RoomChat extends StatefulWidget {
  final String roomName;
  final String opponentName;
  final String opponentAvatar;

  const RoomChat({
    super.key,
    required this.roomName,
    required this.opponentName,
    required this.opponentAvatar,
  });

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final TextEditingController _messageController = TextEditingController();

  // Data Dummy untuk UI Testing
  final List<Map<String, dynamic>> _dummyMessages = [
    {
      "text": "Halo! Gimana progres project Unite kita?",
      "time": "10:00 AM",
      "isMe": false,
    },
    {
      "text": "Aman bang, ini lagi bikin UI buat chat room nya",
      "time": "10:05 AM",
      "isMe": true,
    },
    {
      "text": "Mantap! Pake warna putih aja biar clean",
      "time": "10:06 AM",
      "isMe": false,
    },
    {"text": "Siap king, gas!", "time": "10:07 AM", "isMe": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1, // Shadow tipis pemisah header dan chat
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
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.roomName,
                    style: TextStyle(
                      fontSize: 30.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. AREA LIST CHAT DENGAN BACKGROUND PATTERN
          Expanded(
            child: Stack(
              children: [
                // Lapisan Bawah: Pattern Bintik Tipis
                Positioned.fill(
                  child: CustomPaint(painter: ChatBackgroundPattern()),
                ),
                // Lapisan Atas: List Bubble Chat
                ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  itemCount: _dummyMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _dummyMessages[index];
                    return BubbleChat(
                      message: msg['text'],
                      time: msg['time'],
                      isMe: msg['isMe'],
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. AREA INPUT TEXT
          _buildInputChat(),
        ],
      ),
    );
  }

  // Widget khusus untuk merakit kolom pengetikan pesan
  Widget _buildInputChat() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        // SafeArea agar tidak tertutup indikator home iPhone
        child: Row(
          children: [
            // Text Field Melengkung (Rounded)
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_emotions_outlined,
                      color: Colors.grey,
                      size: 60.sp,
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Message",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 35.sp,
                            color: Colors.grey,
                          ),
                        ),
                        style: TextStyle(fontSize: 35.sp),
                        maxLines:
                            null, // Agar text field bisa memanjang ke bawah kalau teksnya panjang
                      ),
                    ),
                    Icon(Icons.attach_file, color: Colors.grey, size: 60.sp),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20.w),
            // Tombol Kirim (Send) Biru
            Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Padding(
                  padding: EdgeInsets.only(
                    left: 10.w,
                  ), // Menggeser icon send sedikit ke tengah
                  child: Icon(Icons.send, color: Colors.white, size: 50.sp),
                ),
                onPressed: () {
                  // Aksi kirim pesan sementara
                  debugPrint("Mengirim: ${_messageController.text}");
                  _messageController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// KELAS PELUKIS: Untuk membuat pola bintik di background
// ==================================================
class ChatBackgroundPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
          .withOpacity(0.08) // Sangat transparan
      ..style = PaintingStyle.fill;

    const spacing = 20.0; // Jarak antar titik
    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(Offset(i, j), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
