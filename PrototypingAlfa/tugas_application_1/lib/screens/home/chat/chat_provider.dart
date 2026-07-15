import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart'; // Sesuaikan path Config.baseUrl Anda

// ==========================================
// 1. DATA MODELS
// ==========================================

// Model untuk Room Chat Spesifik (Anak Tangga)
class ChatRoomModel {
  final String conversationId;
  final String topicName;
  final String updatedAt;

  ChatRoomModel({required this.conversationId, required this.topicName, required this.updatedAt});
}

// Model untuk Profil Accordion (Induk)
class ChatProfileModel {
  final int opponentId;
  final String opponentName;
  final String opponentAvatar;
  final List<ChatRoomModel> rooms; // Menyimpan daftar room milik user ini

  ChatProfileModel({
    required this.opponentId,
    required this.opponentName,
    required this.opponentAvatar,
    required this.rooms,
  });
}

// Model untuk Rekomendasi Teman Chat
class RecommendationModel {
  final int id;
  final String displayName;
  final String profilePicUrl;

  RecommendationModel({required this.id, required this.displayName, required this.profilePicUrl});
}

// ==========================================
// 2. RIVERPOD PROVIDERS
// ==========================================

// A. Provider untuk Mengambil & Mengelompokkan Data Chat Pararel
// Membutuhkan userId yang sedang login sebagai parameter
final chatConversationsProvider = FutureProvider.family<List<ChatProfileModel>, int>((ref, userId) async {
  final response = await http.get(Uri.parse("${Config.baseUrl}/chat/get_conversations?user_id=$userId"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      final List rawData = data['data'];

      // LOGIKA GROUPING SAKTI
      // Mengubah baris flat dari MySQL menjadi struktur Nested Accordion
      Map<int, ChatProfileModel> groupedData = {};

      for (var item in rawData) {
        final opponent = item['opponent'];
        final int oppId = opponent['id'];

        final room = ChatRoomModel(
          conversationId: item['conversation_id'],
          topicName: item['topic_name'],
          updatedAt: item['updated_at'],
        );

        if (groupedData.containsKey(oppId)) {
          // Jika profil sudah ada, tambahkan room baru ke dalam list miliknya
          groupedData[oppId]!.rooms.add(room);
        } else {
          // Jika belum ada, buat induk profil baru
          groupedData[oppId] = ChatProfileModel(
            opponentId: oppId,
            opponentName: opponent['name'],
            opponentAvatar: opponent['avatar_url'],
            rooms: [room],
          );
        }
      }

      return groupedData.values.toList();
    }
  }
  throw Exception("Gagal mengambil data chat");
});

// B. Provider untuk Mengambil Data Rekomendasi Chat
final chatRecommendationsProvider = FutureProvider.family<List<RecommendationModel>, int>((ref, userId) async {
  final response = await http.get(Uri.parse("${Config.baseUrl}/chat/get_chat_recommendations?user_id=$userId"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      final List rawData = data['data'];

      return rawData
          .map(
            (e) =>
                RecommendationModel(id: e['id'], displayName: e['display_name'], profilePicUrl: e['profile_pic_url']),
          )
          .toList();
    }
  }
  throw Exception("Gagal mengambil rekomendasi");
});
