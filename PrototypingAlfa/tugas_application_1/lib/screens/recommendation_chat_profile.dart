import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendationChatProfile extends StatelessWidget {
  final String displayName;
  final String profilePicUrl;
  final VoidCallback onAdd;

  const RecommendationChatProfile({
    super.key,
    required this.displayName,
    required this.profilePicUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 25.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50.w,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profilePicUrl.isNotEmpty
                ? NetworkImage(profilePicUrl)
                : null,
            child: profilePicUrl.isEmpty
                ? Icon(Icons.person, color: Colors.white, size: 50.sp)
                : null,
          ),
          SizedBox(width: 30.w),
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 60.h,
            width: 120.w,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                "Add",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
