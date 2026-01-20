import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 🔥 JANGAN LUPA IMPORT INI
import 'verification_badge.dart';

class CommentItem extends StatefulWidget {
  final Map comment;
  final int currentUserId;
  final Function(int commentId) onDelete;

  const CommentItem({super.key, required this.comment, required this.currentUserId, required this.onDelete});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;

  void _showOptions() {
    int ownerId = widget.comment['user_id'];
    bool isMine = ownerId == widget.currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Background asli transparan
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. KOTAK MENU UTAMA (Judul + Tombol Action)
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
                  child: Column(
                    children: [
                      // 🔥 JUDUL "OPTIONS"
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 25.h),
                        child: Text(
                          "Options",
                          style: TextStyle(
                            fontSize: 30.sp,
                            color: Colors.grey.shade500, // Warna abu soft
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // GARIS PEMBATAS TIPIS
                      Divider(height: 1, color: Colors.grey.shade300, thickness: 1),

                      // TOMBOL ACTION (Delete / Report)
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (isMine) {
                            widget.onDelete(widget.comment['id']);
                          } else {
                            // 🔥 GANTI SCAFFOLD MESSENGER DENGAN INI 🔥
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent, // Biar gak gelap banget backgroundnya
                              builder: (context) {
                                // ⏳ LOGIC BIAR HILANG SENDIRI (2 Detik)
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                });

                                return Center(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 40.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.9), // Hitam pekat transparan dikit
                                        borderRadius: BorderRadius.circular(40.r),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10)),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min, // Bungkus konten aja
                                        children: [
                                          Icon(Icons.check_circle_outline, color: Colors.white, size: 80.sp),
                                          SizedBox(height: 20.h),
                                          Text(
                                            "Thanks for reporting",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 32.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        // Kasih radius di bawah aja biar atasnya rata kena garis
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.r),
                          bottomRight: Radius.circular(30.r),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 30.h),
                          alignment: Alignment.center,
                          child: Text(
                            isMine ? "Delete Comment" : "Report Comment",
                            style: TextStyle(fontSize: 40.sp, color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15.h), // Jarak
                // 2. TOMBOL CANCEL
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30.h),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r)),
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 40.sp, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. DATA USER (FLAT)
    // Kita baca langsung dari root karena backend sudah kita set FLAT
    String displayName = widget.comment['display_name'] ?? widget.comment['username'] ?? "User";
    String profilePicUrl = widget.comment['profile_pic_url'] ?? "";
    String tier = widget.comment['tier'] ?? 'regular';

    final double commentFontSize = 35.sp;
    final double actionFontSize = 30.sp;
    final double heartIconTopPadding = 60.h;

    final TextStyle textStyle = TextStyle(color: Colors.black, fontSize: commentFontSize, height: 1.3);

    return GestureDetector(
      onLongPress: _showOptions,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(bottom: 40.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. AVATAR (VERSI KUAT - CACHED NETWORK IMAGE)
            // Ini logika yang sama persis dengan PostItem
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey.shade200,
              child: (profilePicUrl.isNotEmpty)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: profilePicUrl,
                        fit: BoxFit.cover,
                        width: 100.r,
                        height: 100.r,
                        // Kalau loading, kasih warna abu
                        placeholder: (context, url) => Container(color: Colors.grey.shade200),
                        // Kalau error/gagal load, kasih Icon Orang
                        errorWidget: (context, url, error) => Icon(Icons.person, color: Colors.grey, size: 50.sp),
                      ),
                    )
                  : Icon(Icons.person, color: Colors.grey, size: 50.sp),
            ),

            SizedBox(width: 30.w),

            // 3. KONTEN KOMENTAR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username / Display Name
                  Row(
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.sp),
                      ),
                      SizedBox(width: 4.w),
                      VerificationBadge(tier: tier, size: 30.sp),
                    ],
                  ),
                  SizedBox(height: 0.h),

                  // Isi Komen
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final String text = widget.comment['comment_text'] ?? "";
                      final span = TextSpan(text: text, style: textStyle);
                      final tp = TextPainter(text: span, maxLines: 2, textDirection: TextDirection.ltr);
                      tp.layout(maxWidth: constraints.maxWidth);

                      final bool hasOverflow = tp.didExceedMaxLines;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: textStyle,
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            children: [
                              Text(
                                "Reply",
                                style: TextStyle(
                                  fontSize: actionFontSize,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (hasOverflow) ...[
                                SizedBox(width: 30.w),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _isExpanded = !_isExpanded);
                                  },
                                  child: Text(
                                    _isExpanded ? "Less" : "More",
                                    style: TextStyle(
                                      fontSize: actionFontSize,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // 4. ICON LOVE
            SizedBox(width: 20.w),
            Padding(
              padding: EdgeInsets.only(top: heartIconTopPadding),
              child: Icon(Icons.favorite_border, size: 40.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
