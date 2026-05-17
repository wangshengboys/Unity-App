import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config.dart'; // Sesuaikan path Config Anda

class ReqBadgePage extends StatefulWidget {
  final int userId;
  final String currentTier;

  const ReqBadgePage({super.key, required this.userId, required this.currentTier});

  @override
  State<ReqBadgePage> createState() => _ReqBadgePageState();
}

class _ReqBadgePageState extends State<ReqBadgePage> {
  bool _isLoading = false;
  bool _hasPendingRequest = false;
  bool _isCheckingStatus = true; // 🔥 State baru untuk loading awal saat cek database

  @override
  void initState() {
    super.initState();
    _checkPendingStatus(); // 🔥 Jalankan pengecekan setiap kali halaman dibuka
  }

  // 🔥 FUNGSI BARU: Cek ke database lewat Python
  Future<void> _checkPendingStatus() async {
    String url = "${Config.baseUrl}/check_pending_request?user_id=${widget.userId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _hasPendingRequest = data['has_pending'] ?? false;
        });
      }
    } catch (e) {
      print("Gagal mengambil status pending: $e");
    } finally {
      setState(() {
        _isCheckingStatus = false; // Selesai mengecek, tampilkan UI utama
      });
    }
  }

  // Fungsi untuk kirim request badge
  Future<void> _submitRequest(String requestedTier) async {
    setState(() {
      _isLoading = true;
    });

    String url = "${Config.baseUrl}/request_badge";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": widget.userId, "requested_tier": requestedTier}),
      );

      var data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _showSnackBar(data['message'] ?? "Permintaan berhasil dikirim!", Colors.green);
        setState(() {
          _hasPendingRequest = true;
        });
      } else {
        _showSnackBar(data['message'] ?? "Gagal mengirim permintaan.", Colors.red);
        if (data['message'] != null && data['message'].toString().contains('diproses')) {
          setState(() {
            _hasPendingRequest = true;
          });
        }
      }
    } catch (e) {
      _showSnackBar("Gagal terhubung ke server!", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 35.sp)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 60.sp),
        ),
        title: Text(
          "Request Badge",
          style: TextStyle(color: Colors.black, fontSize: 40.sp, fontWeight: FontWeight.bold),
        ),
      ),
      // 🔥 JIKA SEDANG CEK DB, TAMPILKAN SPINNER UTAMA
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(50.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status Akun Saat Ini:",
                        style: TextStyle(fontSize: 35.sp, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                        decoration: BoxDecoration(
                          color: _getTierColor(widget.currentTier).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(color: _getTierColor(widget.currentTier), width: 3.w),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: _getTierColor(widget.currentTier), size: 50.sp),
                            SizedBox(width: 20.w),
                            Text(
                              widget.currentTier.toUpperCase(),
                              style: TextStyle(
                                fontSize: 40.sp,
                                fontWeight: FontWeight.bold,
                                color: _getTierColor(widget.currentTier),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 60.h),

                      if (widget.currentTier == 'gold')
                        _getGoldMaxMessage()
                      else ...[
                        Text(
                          "Pilih Badge yang Diajukan:",
                          style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 40.h),

                        if (widget.currentTier == 'regular')
                          _buildBadgeCard(
                            title: "Blue Badge",
                            desc: "Cocok untuk akun personal & kreator yang sedang berkembang.",
                            color: Colors.blue,
                            tierTarget: "blue",
                          ),

                        if (widget.currentTier == 'regular' || widget.currentTier == 'blue')
                          _buildBadgeCard(
                            title: "Gold Badge",
                            desc: "Khusus untuk akun bisnis, vendor resmi, dan komunitas besar.",
                            color: Colors.orange.shade600,
                            tierTarget: "gold",
                          ),
                      ],
                    ],
                  ),
                ),

                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator(color: Colors.blue)),
                  ),
              ],
            ),
    );
  }

  Widget _getGoldMaxMessage() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.workspace_premium, color: Colors.orange.shade600, size: 250.sp),
          SizedBox(height: 40.h),
          Text(
            "Anda berada di tier tertinggi!",
            style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          Text(
            "Akun Anda sudah memiliki status Verified Gold. Tidak ada verifikasi lanjutan yang diperlukan.",
            style: TextStyle(fontSize: 35.sp, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String desc,
    required Color color,
    required String tierTarget,
  }) {
    Color cardColor = _hasPendingRequest ? Colors.grey.shade400 : color;
    String buttonText = _hasPendingRequest ? "Sedang Diproses..." : "Ajukan $title";

    return Container(
      margin: EdgeInsets.only(bottom: 40.h),
      padding: EdgeInsets.all(50.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20.r, offset: Offset(0, 10.h))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: cardColor, size: 70.sp),
              SizedBox(width: 20.w),
              Text(
                title,
                style: TextStyle(fontSize: 45.sp, fontWeight: FontWeight.bold, color: cardColor),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            desc,
            style: TextStyle(fontSize: 32.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 120.h,
            child: ElevatedButton(
              onPressed: _hasPendingRequest ? null : () => _submitRequest(tierTarget),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardColor,
                disabledBackgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontSize: 38.sp,
                  color: _hasPendingRequest ? Colors.grey.shade500 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    if (tier == 'gold') return Colors.orange.shade600;
    if (tier == 'blue') return Colors.blue;
    return Colors.grey.shade600;
  }
}
