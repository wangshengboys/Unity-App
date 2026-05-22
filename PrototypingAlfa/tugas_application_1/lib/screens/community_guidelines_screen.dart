import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../config.dart'; // Sesuaikan path
import 'auth/login_page.dart'; // Sesuaikan path

class CommunityGuidelinesScreen extends StatefulWidget {
  final int userId;
  const CommunityGuidelinesScreen({super.key, required this.userId});

  @override
  State<CommunityGuidelinesScreen> createState() => _CommunityGuidelinesScreenState();
}

class _CommunityGuidelinesScreenState extends State<CommunityGuidelinesScreen> {
  bool _isChecked = false;
  bool _isLoading = false;

  void _logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  Future<void> _restoreAccount() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/restore_account"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": widget.userId}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          _showWelcomeBackDialog();
        }
      }
    } catch (e) {
      debugPrint("Error restore: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWelcomeBackDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        title: const Icon(Icons.verified, color: Colors.blue, size: 80),
        content: Text(
          "Welcome back! Your access has been fully restored. Please log in again to continue.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => _logout(),
            child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
          onPressed: _logout,
          icon: Icon(Icons.logout, color: Colors.red, size: 70.sp),
        ),
        title: Text(
          "Account Restored",
          style: TextStyle(color: Colors.black, fontSize: 45.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(50.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(Icons.check_circle_outline, color: Colors.green, size: 250.sp),
                  ),
                  SizedBox(height: 50.h),
                  Text(
                    "Good news!",
                    style: TextStyle(fontSize: 70.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    "We reviewed your account and found that it follows our Community Guidelines. Your account has been restored. We're sorry for the inconvenience.\n\nTo ensure a safe community, please review our guidelines before logging back in.",
                    style: TextStyle(fontSize: 38.sp, color: Colors.black87, height: 1.5),
                  ),
                  SizedBox(height: 60.h),
                  Container(
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      "Unity's Community Guidelines prioritize safety, respect, and authenticity. Hate speech, harassment, spam, and impersonation are strictly prohibited.",
                      style: TextStyle(fontSize: 32.sp, color: Colors.black54, height: 1.5),
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isChecked,
                        activeColor: Colors.blue,
                        onChanged: (val) => setState(() => _isChecked = val ?? false),
                      ),
                      Expanded(
                        child: Text(
                          "I understand and commit to following Unity's Community Guidelines.",
                          style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 2.w),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 130.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isChecked ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                    elevation: 0,
                  ),
                  onPressed: (_isChecked && !_isLoading) ? _restoreAccount : null,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Yes, I Agree",
                          style: TextStyle(fontSize: 45.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
