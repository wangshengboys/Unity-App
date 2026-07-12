import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Import widget yang baru dibuat
import '../../chat_profile_item.dart';
import '../../room_chat_item.dart';
import '../../recommendation_chat_profile.dart';

class ChatPage extends StatefulWidget {
  final int userId;

  const ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Menyimpan ID profil mana yang sedang terbuka (expand)
  String? expandedUserId;
  final TextEditingController _roomNameController = TextEditingController();

  // Fungsi Popup gaya iOS dengan latar putih murni
  void _showAddRoomPopup(String username) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("New Room Chat", style: TextStyle(fontSize: 35.sp)),
          content: Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: CupertinoTextField(
              controller: _roomNameController,
              placeholder: "Room Name (e.g. Project A)",
              padding: EdgeInsets.all(25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                _roomNameController.clear();
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                // TODO: Eksekusi API create_conversation di sini
                debugPrint("Membuat room: ${_roomNameController.text}");
                _roomNameController.clear();
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _toggleExpand(String id) {
    setState(() {
      if (expandedUserId == id) {
        expandedUserId = null; // Tutup jika ditekan lagi
      } else {
        expandedUserId =
            id; // Buka yang baru ditekan (yang lain otomatis tutup)
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 60.sp),
        ),
        title: Text(
          "Massages", // Mengikuti teks di gambar referensi
          style: TextStyle(
            color: Colors.black,
            fontSize: 40.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DAFTAR CHAT AKTIF ---

            // Dummy Data 1: Erza Scarlet (Expanded)
            ChatProfileItem(
              displayName: "Erza Scarlet",
              profilePicUrl: "https://i.pravatar.cc/150?img=1", // Placeholder
              isExpanded: expandedUserId == "user_1",
              onExpandToggle: () => _toggleExpand("user_1"),
              onAddRoomTap: () => _showAddRoomPopup("Erza Scarlet"),
              rooms: [
                RoomChatItem(
                  roomName: "Daily Conversation",
                  icon: Icons.chat_bubble_outline,
                  onTap: () {},
                ),
                RoomChatItem(
                  roomName: "Job",
                  icon: Icons.assignment_outlined,
                  onTap: () {},
                ),
                RoomChatItem(
                  roomName: "Game",
                  icon: Icons.videogame_asset_outlined,
                  onTap: () {},
                ),
                RoomChatItem(
                  roomName: "Learning",
                  icon: Icons.menu_book_outlined,
                  onTap: () {},
                ),
                RoomChatItem(
                  roomName: "Bussiness",
                  icon: Icons.bar_chart_outlined,
                  onTap: () {},
                ),
              ],
            ),

            // Dummy Data 2: Sakamoto
            ChatProfileItem(
              displayName: "Sakamoto",
              profilePicUrl: "https://i.pravatar.cc/150?img=11",
              isExpanded: expandedUserId == "user_2",
              onExpandToggle: () => _toggleExpand("user_2"),
              onAddRoomTap: () => _showAddRoomPopup("Sakamoto"),
              rooms: const [],
            ),

            // Dummy Data 3: Gon
            ChatProfileItem(
              displayName: "Gon",
              profilePicUrl: "https://i.pravatar.cc/150?img=12",
              isExpanded: expandedUserId == "user_3",
              onExpandToggle: () => _toggleExpand("user_3"),
              onAddRoomTap: () => _showAddRoomPopup("Gon"),
              rooms: const [],
            ),

            SizedBox(height: 30.h),

            // --- 2. HEADER RECOMMENDATION ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Center(
                child: Text(
                  "Recomendation",
                  style: TextStyle(
                    fontSize: 35.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),

            // --- 3. DAFTAR RECOMMENDATION ---
            RecommendationChatProfile(
              displayName: "Madara Uchiha",
              profilePicUrl: "https://i.pravatar.cc/150?img=13",
              onAdd: () {
                debugPrint("Tambah Madara");
              },
            ),
            RecommendationChatProfile(
              displayName: "Anby Demara",
              profilePicUrl: "https://i.pravatar.cc/150?img=14",
              onAdd: () {
                debugPrint("Tambah Anby");
              },
            ),

            SizedBox(height: 100.h), // Ruang kosong di bawah
          ],
        ),
      ),
    );
  }
}
