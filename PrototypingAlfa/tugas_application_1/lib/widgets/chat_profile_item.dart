import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'room_chat_item.dart';

class ChatProfileItem extends StatelessWidget {
  final String displayName;
  final String profilePicUrl;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final List<RoomChatItem> rooms;
  final VoidCallback onAddRoomTap;

  const ChatProfileItem({
    super.key,
    required this.displayName,
    required this.profilePicUrl,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.rooms,
    required this.onAddRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Profil (Bisa diklik untuk expand/collapse)
        InkWell(
          onTap: onExpandToggle,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50.w,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
                  child: profilePicUrl.isEmpty ? Icon(Icons.person, color: Colors.white, size: 50.sp) : null,
                ),
                SizedBox(width: 30.w),
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
                  size: isExpanded ? 60.sp : 40.sp,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),

        // Area Expand (Daftar Room Chat)
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Container(
            color: Colors.white,
            child: Column(
              children: [
                ...rooms,
                // Tombol Add More Room Chat
                InkWell(
                  onTap: onAddRoomTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue, size: 35.sp),
                        SizedBox(width: 15.w),
                        Text(
                          "add more room chat",
                          style: TextStyle(color: Colors.blue, fontSize: 30.sp, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider tebal penutup expand
                Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
              ],
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
