import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomChatItem extends StatelessWidget {
  final String roomName;
  final IconData icon;
  final VoidCallback onTap;

  const RoomChatItem({
    super.key,
    required this.roomName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            // Ikon dengan latar belakang lingkaran abu-abu
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87, size: 40.sp),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: Text(
                roomName,
                style: TextStyle(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
