import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatOptionOverlay {
  static void show({
    required BuildContext context,
    required String roomName,
    required String opponentName,
    required String opponentAvatar,
    required VoidCallback onDeleteTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 60.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TUMPANG TINDIH ---
              Row(
                children: [
                  SizedBox(
                    width: 130.w,
                    height: 100.w,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50.w,
                          backgroundImage: NetworkImage(opponentAvatar),
                          backgroundColor: Colors.grey.shade300,
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 50.w,
                              backgroundColor: Colors.grey.shade200,
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 45.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(text: "$opponentName - "),
                          TextSpan(
                            text: roomName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 60.h, color: Colors.grey.shade300),

              // --- BAGIAN ACTION ---
              Text(
                "Action",
                style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(Icons.edit_outlined, "Appearance"),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.lock_outline,
                      "Lock this conversation",
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.info_outline,
                      "About this conversation",
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.push_pin_outlined,
                      "Pinned this conversation",
                    ),
                    _buildDivider(),
                    _buildMenuItem(Icons.star_outline, "Add to Favorite"),
                  ],
                ),
              ),

              SizedBox(height: 50.h),

              // --- BAGIAN MORE ---
              Text(
                "More",
                style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      Icons.report_problem_outlined,
                      "Report this conversation",
                      isDanger: true,
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      Icons.delete_outline,
                      "Delete this conversation",
                      isDanger: true,
                      onTap: onDeleteTap,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h), // Safe area bottom
            ],
          ),
        );
      },
    );
  }

  static Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap:
          onTap ??
          () {
            // Dummy action untuk opsi yang belum ada backend-nya
            debugPrint("Tapped: $title");
          },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 35.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 55.sp,
              color: isDanger ? Colors.red : Colors.black87,
            ),
            SizedBox(width: 40.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 35.sp,
                color: isDanger ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
    );
  }
}
