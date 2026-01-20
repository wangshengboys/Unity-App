import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class UserEventCard extends StatelessWidget {
  final String title;
  final String startDate;
  final String endDate;
  final String? posterUrl;
  final String? communityIconUrl;
  final VoidCallback onTapDetail;
  final bool isRegistered; // 🔥 1. Tambah variabel ini

  const UserEventCard({
    super.key,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.posterUrl,
    required this.communityIconUrl,
    required this.onTapDetail,
    this.isRegistered = false, // 🔥 Default false
  });

  String _formatDateRange() {
    try {
      DateTime start = DateTime.parse(startDate);
      DateTime end = DateTime.parse(endDate);
      String startStr = DateFormat('d MMMM').format(start);
      String endStr = DateFormat('d MMMM').format(end);
      return "$startStr  -  $endStr";
    } catch (e) {
      return startDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, spreadRadius: 2, offset: Offset.zero),
        ],
      ),
      child: Row(
        children: [
          // KIRI: POSTER & LOGO
          SizedBox(
            width: 300.w,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40.r), bottomLeft: Radius.circular(40.r)),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: (posterUrl != null && posterUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(posterUrl!)
                            : const AssetImage('assets/images/placeholder_event.jpg') as ImageProvider,
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15.w),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CircleAvatar(
                        radius: 70.r,
                        backgroundColor: Colors.grey.shade200,
                        // 🔥 ICON SEKARANG MUNCUL (Kalau backend kirim)
                        backgroundImage: (communityIconUrl != null && communityIconUrl!.isNotEmpty)
                            ? CachedNetworkImageProvider(communityIconUrl!)
                            : null,
                        child: (communityIconUrl == null || communityIconUrl!.isEmpty)
                            ? Icon(Icons.groups, size: 50.sp, color: Colors.grey)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(Icons.verified, color: Colors.orange, size: 40.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KANAN: INFO & TOMBOL
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        _formatDateRange(),
                        style: TextStyle(fontSize: 30.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  // 🔥 2. LOGIKA TOMBOL BERUBAH WARNA & TEKS
                  SizedBox(
                    width: double.infinity,
                    height: 80.h,
                    child: ElevatedButton(
                      onPressed: onTapDetail,
                      style: ElevatedButton.styleFrom(
                        // Kalau registered -> Hijau, Kalau belum -> Biru
                        backgroundColor: isRegistered ? Colors.green : Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      child: Text(
                        isRegistered ? "Registered" : "Event Detail", // Ubah Teks
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
