import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/home/chat/chat_option_overlay.dart';

class RoomChatItem extends StatelessWidget {
  final String conversationId;
  final String roomName;
  final IconData icon;
  final String opponentName;
  final String opponentAvatar;
  final VoidCallback onTap;
  final Function(String) onDelete;

  const RoomChatItem({
    super.key,
    required this.conversationId,
    required this.roomName,
    required this.icon,
    required this.opponentName,
    required this.opponentAvatar,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: () {
        // 🔥 Langsung memunculkan overlay tanpa lewat titik tiga
        ChatOptionOverlay.show(
          context: context,
          roomName: roomName,
          opponentName: opponentName,
          opponentAvatar: opponentAvatar,
          onDeleteTap: () {
            Navigator.pop(context); // Tutup overlay
            onDelete(conversationId); // Eksekusi hapus ke backend
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.black87, size: 40.sp),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: Text(
                roomName,
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
