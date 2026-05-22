import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'auth/login_page.dart'; // Sesuaikan path

class AppealPendingScreen extends StatelessWidget {
  const AppealPendingScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
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
          "Appeal Submitted",
          style: TextStyle(color: Colors.black, fontSize: 45.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(60.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pending_actions, color: Colors.orange, size: 300.sp),
            SizedBox(height: 60.h),
            Text(
              "We'll take another look\nat your account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 70.sp, fontWeight: FontWeight.bold, height: 1.2),
            ),
            SizedBox(height: 40.h),
            Text(
              "We usually review appeals within 24 hours, but it may take up to 48 hours in some cases. We'll notify you once a decision has been made.\n\nThank you for your patience.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 38.sp, color: Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
