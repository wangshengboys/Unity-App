import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../chat_profile_item.dart';
import '../../room_chat_item.dart';
import '../../recommendation_chat_profile.dart';
import '../../chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  final int userId;

  const ChatPage({super.key, required this.userId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  String? expandedUserId;
  final TextEditingController _roomNameController = TextEditingController();

  // API CALL
  Future<void> _createNewRoom(int opponentId, String topicName) async {
    try {
      final url = Uri.parse("${Config.baseUrl}/chat/create_conversation");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "opponent_id": opponentId,
          "topic_name": topicName,
        }),
      );

      if (response.statusCode == 201) {
        // 🔥 KEAJAIBAN RIVERPOD: Invalidate akan memaksa UI me-refresh data dari backend
        ref.invalidate(chatConversationsProvider(widget.userId));
        ref.invalidate(chatRecommendationsProvider(widget.userId));
      } else {
        debugPrint("Gagal membuat room: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error create room: $e");
    }
  }

  // --- POPUP GAYA IOS ---
  void _showAddRoomPopup(int opponentId, String username) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "New Room Chat\nwith $username",
            style: TextStyle(fontSize: 30.sp),
            textAlign: TextAlign.center,
          ),
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
              onPressed: () async {
                if (_roomNameController.text.trim().isNotEmpty) {
                  final topic = _roomNameController.text.trim();
                  _roomNameController.clear();
                  Navigator.pop(context); // Tutup popup dulu

                  // Jalankan fungsi tembak API
                  await _createNewRoom(opponentId, topic);
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRoom(String conversationId) async {
    try {
      final url = Uri.parse("${Config.baseUrl}/chat/delete_conversation");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "conversation_id": conversationId,
          "user_id": widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        // 🔥 KEAJAIBAN RIVERPOD: Langsung refresh UI agar room yang dihapus lenyap dari layar
        ref.invalidate(chatConversationsProvider(widget.userId));
        debugPrint("Room berhasil dihapus!");
      } else {
        debugPrint("Gagal menghapus room: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error delete room: $e");
    }
  }

  void _toggleExpand(String id) {
    setState(() {
      if (expandedUserId == id) {
        expandedUserId = null;
      } else {
        expandedUserId = id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 PANTAU DATA DARI PROVIDER
    final chatListAsync = ref.watch(chatConversationsProvider(widget.userId));
    final recommendationAsync = ref.watch(
      chatRecommendationsProvider(widget.userId),
    );

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
          "Massages",
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
            // --- 1. DAFTAR CHAT AKTIF (DARI DATABASE) ---
            chatListAsync.when(
              data: (chatProfiles) {
                if (chatProfiles.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.h),
                    child: Center(
                      child: Text(
                        "No active chats",
                        style: TextStyle(fontSize: 35.sp, color: Colors.grey),
                      ),
                    ),
                  );
                }

                // Me-mapping data asli ke dalam Widget Accordion
                return Column(
                  children: chatProfiles.map((profile) {
                    return ChatProfileItem(
                      displayName: profile.opponentName,
                      profilePicUrl: profile.opponentAvatar,
                      isExpanded:
                          expandedUserId == profile.opponentId.toString(),
                      onExpandToggle: () =>
                          _toggleExpand(profile.opponentId.toString()),
                      onAddRoomTap: () => _showAddRoomPopup(
                        profile.opponentId,
                        profile.opponentName,
                      ),
                      rooms: profile.rooms.map((room) {
                        return RoomChatItem(
                          conversationId: room
                              .conversationId, // Lempar ID room untuk backend
                          roomName: room.topicName,
                          icon: Icons.chat_bubble_outline,
                          opponentName: profile
                              .opponentName, // Lempar nama lawan bicara untuk overlay
                          opponentAvatar: profile
                              .opponentAvatar, // Lempar foto profil untuk overlay
                          onTap: () {
                            // TODO: Navigasi ke ruang obrolan asli
                            debugPrint(
                              "Masuk ke room ID: ${room.conversationId}",
                            );
                          },
                          onDelete: (deletedId) async {
                            // Panggil fungsi hapus yang baru kita buat
                            await _deleteRoom(deletedId);
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
              loading: () => Padding(
                padding: EdgeInsets.all(50.h),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
              error: (error, stack) => Center(child: Text("Error: $error")),
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

            // --- 3. DAFTAR RECOMMENDATION (DARI DATABASE) ---
            recommendationAsync.when(
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.h),
                    child: Center(
                      child: Text(
                        "No recommendations",
                        style: TextStyle(fontSize: 30.sp, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Column(
                  children: recommendations.map((rec) {
                    return RecommendationChatProfile(
                      displayName: rec.displayName,
                      profilePicUrl: rec.profilePicUrl,
                      onAdd: () async {
                        // Langsung buat room "Main Chat" jika ditekan
                        await _createNewRoom(rec.id, "Main Chat");
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => Padding(
                padding: EdgeInsets.all(40.h),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              ),
              error: (error, stack) => Center(child: Text("Error: $error")),
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
