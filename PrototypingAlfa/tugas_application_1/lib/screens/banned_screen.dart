import 'dart:async';
import 'dart:convert'; // 🔥 Import JSON
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http; // 🔥 Import HTTP
import '../config.dart'; // 🔥 Import Config (sesuaikan path jika perlu)
import 'ban_appeal_form_page.dart';
import 'auth/login_page.dart';
import 'appeal_pending_screen.dart';
import 'appeal_rejected_screen.dart';
import 'community_guidelines_screen.dart';

class BannedScreen extends StatefulWidget {
  final int userId;
  final String username;

  const BannedScreen({super.key, required this.userId, required this.username});

  @override
  State<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends State<BannedScreen> {
  // Timer Dummy: Kita set 360 hari
  int _daysLeft = 360;
  int _hoursLeft = 23;
  int _minutesLeft = 59;
  late Timer _timer;

  // Variabel untuk menampung URL foto profil
  String userProfilePic = "";

  @override
  void initState() {
    super.initState();

    // 🔥 1. Panggil fungsi untuk mengambil foto profil dari backend
    _fetchUserData();

    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_minutesLeft > 0) {
            _minutesLeft--;
          } else {
            _minutesLeft = 59;
            if (_hoursLeft > 0) {
              _hoursLeft--;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // 🔥 2. FUNGSI SAKTI: Ambil Foto Profil dari Backend
  Future<void> _fetchUserData() async {
    try {
      // 1. Ambil Data User (Untuk Foto Profil Madara jika status none)
      final urlUser = Uri.parse("${Config.baseUrl}/check_user_status?user_id=${widget.userId}");
      final responseUser = await http.get(urlUser);

      if (responseUser.statusCode == 200) {
        final data = jsonDecode(responseUser.body);
        if (data['status'] == 'success' && mounted) {
          setState(() {
            userProfilePic = data['profile_pic_url'] ?? "";
          });
        }
      }

      // 2. 🔥 ROUTER LOGIC: Cek Status Banding Terakhir
      final urlAppeal = Uri.parse("${Config.baseUrl}/check_appeal_status/${widget.userId}");
      final responseAppeal = await http.get(urlAppeal);

      if (responseAppeal.statusCode == 200) {
        final appealData = jsonDecode(responseAppeal.body);
        if (appealData['status'] == 'success' && mounted) {
          String status = appealData['data']['status'];

          // Shapeshifting! Lempar ke layar yang sesuai
          if (status == 'pending') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppealPendingScreen()));
          } else if (status == 'rejected') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AppealRejectedScreen()));
          } else if (status == 'approved') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CommunityGuidelinesScreen(userId: widget.userId)),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error Router BannedScreen: $e");
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      // ==========================================
      // HEADER (FIXED TOP)
      // ==========================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, // Mencegah warna berubah
        // 🔥 REVISI: Bayangan tipis yang elegan
        elevation: 3, // Ketinggian bayangan
        shadowColor: Colors.black.withOpacity(0.15), // Warna bayangan transparan (tipis)
        scrolledUnderElevation: 3, // Pastikan bayangan tetap ada saat scroll

        centerTitle: true,
        leading: IconButton(
          onPressed: _logout,
          icon: Icon(Icons.logout, color: Colors.red, size: 70.sp),
        ),
        title: Text(
          "Account Suspended",
          style: TextStyle(color: Colors.black, fontSize: 45.sp, fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // ==========================================
          // BODY CONTENT (SCROLLABLE)
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 40.h),
              child: Column(
                children: [
                  // 🔥 3. FOTO PROFIL SEKARANG AKTIF
                  CircleAvatar(
                    radius: 150.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: userProfilePic.isNotEmpty ? CachedNetworkImageProvider(userProfilePic) : null,
                    child: userProfilePic.isEmpty ? Icon(Icons.person, color: Colors.grey, size: 150.sp) : null,
                  ),

                  SizedBox(height: 60.h),
                  Text(
                    "We suspended\nyour account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 75.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.0, // 🔥 TAMBAHKAN INI (Ubah angkanya sesuai selera)
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Your Account doesn't follow our Community Guidelines and has been suspended.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 38.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 60.h),

                  Container(
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, color: Colors.red, size: 80.sp),
                        SizedBox(width: 30.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 35.sp, color: Colors.black),
                                  children: [
                                    const TextSpan(text: "You have "),
                                    TextSpan(
                                      text: "$_daysLeft days",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                    const TextSpan(text: " left to appeal"),
                                  ],
                                ),
                              ),
                              Text(
                                "After that, your account will be permanently disabled.",
                                style: TextStyle(fontSize: 28.sp, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 35.sp, color: Colors.grey),
                      SizedBox(width: 15.w),
                      Text(
                        "Suspended on $formattedDate",
                        style: TextStyle(fontSize: 32.sp, color: Colors.grey),
                      ),
                    ],
                  ),

                  SizedBox(height: 60.h),
                  Container(
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.verified_outlined,
                          iconColor: Colors.blue,
                          title: "What this means",
                          isHeader: true,
                        ),
                        const Divider(),
                        _buildInfoTile(
                          icon: Icons.grid_view,
                          iconColor: Colors.red.shade400,
                          title: "You can't use Unity",
                          subtitle: "You can't log in or use any features right now.",
                        ),
                        const Divider(),
                        _buildInfoTile(
                          icon: Icons.person_outline,
                          iconColor: Colors.red.shade400,
                          title: "This action isn't permanent yet",
                          subtitle: "You can appeal our decision within 360 days",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),
                  Container(
                    padding: EdgeInsets.all(40.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 55.sp),
                            SizedBox(width: 20.w),
                            Text(
                              "Why this happened",
                              style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 40),
                        Text(
                          "We suspend accounts that violate our Community Guidelines or Terms of Service. This may include suspicious activity, harmful behavior, spam, impersonation, or content that breaks platform rules. If you believe your account was suspended by mistake, you can submit an appeal for manual review. Our team will review your account and notify you once a decision has been made.",
                          style: TextStyle(fontSize: 30.sp, color: Colors.black87, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),

          // ==========================================
          // FOOTER
          // ==========================================
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 40.h, bottom: 40.h, left: 50.w, right: 50.w),
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
                    backgroundColor: const Color(0xFF2D9CDB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    // 🔥 Gunakan await agar BannedScreen menunggu form ditutup
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BanAppealFormPage(userId: widget.userId)),
                    );

                    // Jika form sukses disubmit dan melempar nilai 'true', refresh Router!
                    if (result == true) {
                      _fetchUserData();
                    }
                  },
                  child: Text(
                    "Appeals",
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

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool isHeader = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        crossAxisAlignment: isHeader ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 55.sp),
          SizedBox(width: 30.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 35.sp, fontWeight: isHeader ? FontWeight.bold : FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 28.sp, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
