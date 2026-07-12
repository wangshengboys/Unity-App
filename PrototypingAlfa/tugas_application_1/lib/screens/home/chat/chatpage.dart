import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatPage extends StatefulWidget {
  final int userId; // Menerima userId seperti halaman lainnya

  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Menyamakan dengan notification page[cite: 5]
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,

        // Garis pembatas tipis di bawah AppBar[cite: 5]
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),

        // Tombol Back gaya iOS[cite: 5]
        leading: GestureDetector(
          onTap: () =>
              Navigator.pop(context), // Kembali ke MainScreen[cite: 4, 5]
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 60.sp),
        ),

        // Judul AppBar
        title: Text(
          "Chat",
          style: TextStyle(
            color: Colors.black,
            fontSize: 40.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Tombol icon chat di pojok kanan
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: Aksi saat tombol navigasi chat ditekan (misal: buat pesan baru)
              debugPrint("Tombol tambah chat ditekan");
            },
            child: Padding(
              padding: EdgeInsets.only(
                right: 40.w,
              ), // Jarak dari tepi kanan layar
              child: Image.asset(
                'assets/images/chat_icon_button.png',
                width: 65
                    .w, // Sesuaikan ukurannya agar pas dengan proporsi icon back
                height: 65.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),

      // Body dikosongkan dulu sesuai instruksi
      body: const SizedBox.shrink(),
    );
  }
}
