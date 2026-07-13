import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'chat_option_overlay.dart'; // File overlay yang akan kita buat selanjutnya

class RoomChatItem extends StatefulWidget {
  final String conversationId; // ID unik room untuk backend
  final String roomName;
  final IconData icon;
  final String opponentName; // Untuk header di overlay
  final String opponentAvatar; // Untuk header di overlay
  final VoidCallback onTap;
  final Function(String) onDelete; // Callback ke atas untuk dieksekusi Riverpod

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
  State<RoomChatItem> createState() => _RoomChatItemState();
}

class _RoomChatItemState extends State<RoomChatItem> {
  bool _showOptions = false; // State untuk memunculkan titik 3

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: () {
        setState(() {
          _showOptions = !_showOptions; // Toggle titik 3
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: Colors.black87, size: 40.sp),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: Text(
                widget.roomName,
                style: TextStyle(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            // Animasi kemunculan titik 3
            if (_showOptions)
              IconButton(
                onPressed: () {
                  // Munculkan overlay dan lempar datanya
                  ChatOptionOverlay.show(
                    context: context,
                    roomName: widget.roomName,
                    opponentName: widget.opponentName,
                    opponentAvatar: widget.opponentAvatar,
                    onDeleteTap: () {
                      Navigator.pop(context); // Tutup overlay dulu
                      widget.onDelete(widget.conversationId); // Eksekusi hapus
                      setState(
                        () => _showOptions = false,
                      ); // Sembunyikan titik 3
                    },
                  );
                },
                icon: Icon(Icons.more_horiz, size: 60.sp, color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
