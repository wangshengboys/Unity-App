import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../auth/login_page.dart'; // Sesuaikan path

class AppealRejectedScreen extends StatelessWidget {
  const AppealRejectedScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.15),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _logout(context),
          icon: Icon(Icons.logout, color: Colors.red, size: 70.sp),
        ),
        title: Text(
          "Account Disabled",
          style: TextStyle(
            color: Colors.black,
            fontSize: 45.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(60.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, color: Colors.red, size: 300.sp),
            SizedBox(height: 60.h),
            Text(
              "Account Permanently\nDisabled",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.red.shade800,
              ),
            ),
            SizedBox(height: 40.h),
            Text(
              "We reviewed your account and found that it still doesn't follow our Community Guidelines on unacceptable behavior.\n\nYour appeal has been denied, and this account has been permanently disabled. You cannot request another review for this account.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
