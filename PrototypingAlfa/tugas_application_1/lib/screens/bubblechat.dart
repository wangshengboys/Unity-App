import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BubbleChat extends StatelessWidget {
  final String message;
  final String time;
  final bool isMe; // true = biru (kanan), false = abu-abu (kiri)

  const BubbleChat({
    super.key,
    required this.message,
    required this.time,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
        constraints: BoxConstraints(
          maxWidth: 0.75.sw, // Lebar maksimal bubble 75% dari layar
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
            // Sudut patah khas WhatsApp di bagian bawah
            bottomLeft: isMe ? Radius.circular(30.r) : const Radius.circular(0),
            bottomRight: isMe
                ? const Radius.circular(0)
                : Radius.circular(30.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 35.sp,
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              time,
              style: TextStyle(
                fontSize: 25.sp,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
