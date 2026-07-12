import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart'; // Pastikan path config benar

class BanAppealFormPage extends StatefulWidget {
  final int userId;

  const BanAppealFormPage({super.key, required this.userId});

  @override
  State<BanAppealFormPage> createState() => _BanAppealFormPageState();
}

class _BanAppealFormPageState extends State<BanAppealFormPage> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // --- FUNGSI KIRIM BANDING ---
  Future<void> _submitAppeal() async {
    if (_reasonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Tuliskan alasan atau penjelasan Anda!";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/submit_appeal"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": widget.userId,
          "reason": _reasonController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // SUKSES
        if (mounted) {
          _showSuccessDialog(data['message']);
        }
      } else {
        // GAGAL (Contoh: sudah pernah kirim banding)
        if (mounted) {
          setState(() {
            _errorMessage = data['message'] ?? "Gagal mengirim pengajuan.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Terjadi kesalahan koneksi ke server.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 80),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup Dialog Popup
              // 🔥 Kirim nilai 'true' ke BannedScreen agar dia tahu form sukses!
              Navigator.of(context).pop(true);
            },
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          "Appeal Decision",
          style: TextStyle(
            color: Colors.black,
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tell us why we should review your account",
              style: TextStyle(
                fontSize: 55.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Explain clearly why you believe your account was suspended by mistake. Provide any context that might help our team understand the situation.",
              style: TextStyle(fontSize: 32.sp, color: Colors.black54),
            ),
            SizedBox(height: 60.h),

            // BOX INPUT ALASAN
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(
                  color: _errorMessage != null
                      ? Colors.red
                      : Colors.grey.shade300,
                  width: 2.w,
                ),
              ),
              child: TextField(
                controller: _reasonController,
                maxLines: 10,
                style: TextStyle(fontSize: 35.sp, color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter your explanation here...",
                  hintStyle: TextStyle(fontSize: 35.sp, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 20.h, left: 20.w),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            SizedBox(height: 80.h),

            // PEDOMAN SINGKAT (Info Box)
            Container(
              padding: EdgeInsets.all(30.w),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 40.sp,
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Text(
                      "Reviewing usually takes 24-48 hours. We'll notify you once a decision has been made.",
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100.h),

            // SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 120.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF448AFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _submitAppeal,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Submit Appeal",
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
