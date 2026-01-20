import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'search_post_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

// WIDGETS
import '../widgets/search_user_card.dart';
import '../widgets/search_community_card.dart';
import '../widgets/user_event_card.dart';

// PAGES
import 'profile/profile_page.dart';
import 'profile/visit_profile_page.dart';
import 'communites/community/community_profile_page.dart';
import 'communites/event/user_event_detail_page.dart';

class SearchPage extends StatefulWidget {
  final int userId;
  const SearchPage({super.key, required this.userId});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // STATE: 'default', 'typing', 'result'
  String _searchState = 'default';
  Timer? _debounce;

  TabController? _tabController; // ✅ Boleh kosong (nullable)

  // DATA LIST
  List _defaultPosts = [];
  List _typingUsers = [];

  // HASIL SEARCH (RESULT STATE)
  List _resultUsers = [];
  List _resultCommunities = [];
  List _resultEvents = [];
  List _resultPosts = [];

  bool _isLoading = false;
  bool _isVendor = false;
  bool _isTierLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkUserTier();
    fetchDefaultPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _checkUserTier() async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/get_profile_info?user_id=${widget.userId}&visitor_id=${widget.userId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String tier = data['tier'] ?? 'regular';

        setState(() {
          // Anggap 'gold' dan 'vendor' itu sama
          _isVendor = (tier == 'gold' || tier == 'vendor');
          _isTierLoaded = true;

          // 🔥 4. INIT TAB CONTROLLER SESUAI TIER
          // Kalau Vendor cuma 3 Tab, Kalau User Biasa 5 Tab
          _tabController = TabController(length: _isVendor ? 3 : 5, vsync: this);
        });
      }
    } catch (e) {
      print("Error check tier: $e");
      // Fallback ke user biasa kalau error
      setState(() {
        _isVendor = false;
        _isTierLoaded = true;
        _tabController = TabController(length: 5, vsync: this);
      });
    }
  }

  // 🔥 NAVIGASI PINTAR (OWNER vs VISITOR)
  void _navigateToProfile(Map<String, dynamic> user) {
    int targetId = user['id'];
    String targetUsername = user['username'];

    if (targetId == widget.userId) {
      // 🅰️ KALAU KLIK DIRI SENDIRI -> ProfilePage + Back Button
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            userId: widget.userId,
            showBackButton: true, // 🔥 TAMBAHKAN INI BIAR MUNCUL
          ),
        ),
      );
    } else {
      // 🅱️ KALAU KLIK ORANG LAIN -> VisitProfilePage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisitProfilePage(userId: targetId, username: targetUsername, visitorId: widget.userId),
        ),
      );
    }
  }

  // --- API FUNCTIONS ---

  Future<void> fetchDefaultPosts() async {
    try {
      final response = await http.get(Uri.parse("${Config.baseUrl}/get_all_posts"));
      if (response.statusCode == 200) {
        if (mounted) setState(() => _defaultPosts = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error fetch default posts: $e");
    }
  }

  Future<void> _fetchTypingUsers(String query) async {
    if (query.isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/search?type=user&q=$query&user_id=${widget.userId}"),
      );
      if (response.statusCode == 200) {
        if (mounted) setState(() => _typingUsers = jsonDecode(response.body));
      }
    } catch (e) {
      print("Error typing search: $e");
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse("${Config.baseUrl}/search?type=user&q=$query&user_id=${widget.userId}")),
        http.get(Uri.parse("${Config.baseUrl}/search?type=community&q=$query&user_id=${widget.userId}")),
        http.get(Uri.parse("${Config.baseUrl}/search?type=event&q=$query&user_id=${widget.userId}")),
        http.get(Uri.parse("${Config.baseUrl}/search?type=post&q=$query&user_id=${widget.userId}")),
      ]);

      if (mounted) {
        setState(() {
          _resultUsers = (responses[0].statusCode == 200) ? jsonDecode(responses[0].body) : [];
          _resultCommunities = (responses[1].statusCode == 200) ? jsonDecode(responses[1].body) : [];
          _resultEvents = (responses[2].statusCode == 200) ? jsonDecode(responses[2].body) : [];
          _resultPosts = (responses[3].statusCode == 200) ? jsonDecode(responses[3].body) : [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error perform search: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC INPUT ---

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        setState(() => _searchState = 'default');
      } else {
        setState(() => _searchState = 'typing');
        _fetchTypingUsers(value);
      }
    });
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      setState(() => _searchState = 'result');
      _performSearch(value);
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 100.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w), // Padding dikit biar gak mepet pinggir
              alignment: Alignment.centerLeft, // 🔥 1. INI KUNCINYA (Biar anak-anaknya di tengah vertikal)
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(30.r)),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,

                // Alignment Teks
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 34.sp),

                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 109, 109, 109),
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Icon(Icons.search, color: const Color.fromARGB(255, 116, 116, 116), size: 55.sp),
                  ),
                  prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w), // Kunci ukuran icon
                  // Icon Close (Kanan)
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close, color: Colors.grey, size: 40.sp),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchState = 'default');
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          if (_searchState != 'default') ...[
            SizedBox(width: 20.w),
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchState = 'default');
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 32.sp, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_searchState == 'default') {
      return _buildDefaultState();
    } else if (_searchState == 'typing') {
      return _buildTypingState();
    } else {
      return _buildResultState();
    }
  }

  // STATE 1: DEFAULT
  // Import dulu

  Widget _buildDefaultState() {
    if (_defaultPosts.isEmpty) {
      return Center(
        child: Text(
          "No posts yet",
          style: TextStyle(fontSize: 30.sp, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      // Padding tipis biar rapi
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 🔥 3 KOLOM KE SAMPING
        crossAxisSpacing: 3.w, // Jarak antar kotak (horizontal)
        mainAxisSpacing: 3.w, // Jarak antar kotak (vertikal)
        childAspectRatio: 1, // Rasio 1:1 (Kotak Sempurna)
      ),
      itemCount: _defaultPosts.length,
      itemBuilder: (context, index) {
        final post = _defaultPosts[index];
        final imageUrl = post['image_url'];

        return GestureDetector(
          onTap: () {
            // 🔥 Tetap bisa diklik masuk ke Detail Page baru tadi
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPostDetailPage(postId: post['id'], currentUserId: widget.userId),
              ),
            );
          },
          child: Container(
            color: Colors.grey.shade200, // Warna dasar kalau loading
            child: (imageUrl != null && imageUrl != "")
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover, // 🔥 FULL GAMBAR TANPA SISA
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.grey),
                  )
                : Center(child: Icon(Icons.image, color: Colors.grey)), // Fallback kalau gak ada gambar
          ),
        );
      },
    );
  }

  // STATE 2: TYPING (USERS)
  Widget _buildTypingState() {
    return ListView.builder(
      itemCount: _typingUsers.length,
      itemBuilder: (context, index) {
        final user = _typingUsers[index];
        return SearchUserCard(user: user, onTap: () => _navigateToProfile(user));
      },
    );
  }

  Widget _buildResultState() {
    // Kalau tier belum ke-load, loading dulu biar gak crash
    if (!_isTierLoaded || _tabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
          indicatorColor: const Color.fromARGB(255, 0, 0, 0),
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: false,
          labelPadding: EdgeInsets.zero,

          // 🔥 TABS DINAMIS
          tabs: _isVendor
              ? const [
                  // JIKA VENDOR (3 TAB)
                  Tab(text: "For You"),
                  Tab(text: "Accounts"),
                  Tab(text: "Posts"),
                ]
              : const [
                  // JIKA REGULAR (5 TAB)
                  Tab(text: "For You"),
                  Tab(text: "Accounts"),
                  Tab(text: "Posts"),
                  Tab(text: "Comms"),
                  Tab(text: "Events"),
                ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  // 🔥 ANAK TABS JUGA HARUS DINAMIS URUTANNYA
                  children: _isVendor
                      ? [
                          // ANAK VENDOR (3)
                          _buildForYouTab(),
                          _buildList(
                            _resultUsers,
                            "No accounts found",
                            (item) => SearchUserCard(user: item, onTap: () => _navigateToProfile(item)),
                          ),
                          _buildPostGrid(_resultPosts),
                        ]
                      : [
                          // ANAK REGULAR (5)
                          _buildForYouTab(),
                          _buildList(
                            _resultUsers,
                            "No accounts found",
                            (item) => SearchUserCard(user: item, onTap: () => _navigateToProfile(item)),
                          ),
                          _buildPostGrid(_resultPosts),

                          // Tab Comms
                          _buildList(
                            _resultCommunities,
                            "No communities found",
                            (item) => SearchCommunityCard(
                              community: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommunityProfilePage(communityId: item['id'], currentUserId: widget.userId),
                                ),
                              ),
                            ),
                          ),

                          // Tab Events
                          _buildList(
                            _resultEvents,
                            "No events found",
                            (item) => Padding(
                              padding: EdgeInsets.all(20.w),
                              child: UserEventCard(
                                title: item['title'],
                                startDate: item['start_time'],
                                endDate: item['start_time'],
                                posterUrl: item['image_url'],
                                communityIconUrl: item['community_icon_url'],
                                isRegistered: item['is_registered'] ?? false,
                                onTapDetail: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UserEventDetailPage(eventData: item, currentUserId: widget.userId),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                ),
        ),
      ],
    );
  }

  // 🔥 FUNGSI BARU: GRID KHUSUS HASIL SEARCH POST
  Widget _buildPostGrid(List data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No posts found",
          style: TextStyle(fontSize: 30.sp, color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(2.w), // Padding tipis aja
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
        childAspectRatio: 1,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final post = data[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchPostDetailPage(postId: post['id'], currentUserId: widget.userId),
              ),
            );
          },
          child: Container(
            color: Colors.grey.shade200,
            child: (post['image_url'] != null && post['image_url'] != "")
                ? CachedNetworkImage(imageUrl: post['image_url'], fit: BoxFit.cover)
                : const Icon(Icons.image, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildForYouTab() {
    return SingleChildScrollView(
      // 🔥 1. HAPUS PADDING GLOBAL DISINI (Biarkan 0)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 2. BUNGKUS BAGIAN ATAS DENGAN PADDING MANUAL
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ACCOUNTS SECTION
                if (_resultUsers.isNotEmpty) ...[
                  Text(
                    "Accounts",
                    style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.h),
                  ..._resultUsers.take(3).map((u) => SearchUserCard(user: u, onTap: () => _navigateToProfile(u))),
                  SizedBox(height: 40.h),
                ],

                // 2. COMMUNITIES SECTION
                if (!_isVendor && _resultCommunities.isNotEmpty) ...[
                  Text(
                    "Communities",
                    style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.h),
                  ..._resultCommunities
                      .take(3)
                      .map(
                        (c) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.w),
                          child: SearchCommunityCard(
                            community: c,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommunityProfilePage(communityId: c['id'], currentUserId: widget.userId),
                              ),
                            ),
                          ),
                        ),
                      ),
                  SizedBox(height: 40.h),
                ],

                // 3. EVENTS SECTION
                if (!_isVendor && _resultEvents.isNotEmpty) ...[
                  Text(
                    "Events",
                    style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.h),
                  ..._resultEvents
                      .take(3)
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: UserEventCard(
                            title: e['title'],
                            startDate: e['start_time'],
                            endDate: e['start_time'],
                            posterUrl: e['image_url'],
                            communityIconUrl: e['community_icon_url'],
                            isRegistered: e['is_registered'] ?? false,
                            onTapDetail: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserEventDetailPage(eventData: e, currentUserId: widget.userId),
                              ),
                            ),
                          ),
                        ),
                      ),
                  SizedBox(height: 40.h),
                ],
              ],
            ),
          ),

          // 4. 🔥 POSTS SECTION (FULL WIDTH / MENTOK KANAN KIRI)
          if (_resultPosts.isNotEmpty) ...[
            // Judul tetap pakai Padding biar sejajar sama atas
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                "Posts",
                style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.h),

            // Grid Postingan (Tanpa Padding Samping)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Padding 2 pixel biar gak nempel banget sama sisi layar HP
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 3.w,
                childAspectRatio: 1,
              ),
              itemCount: _resultPosts.length > 9 ? 9 : _resultPosts.length, // Tampilkan max 9 di For You
              itemBuilder: (context, index) {
                final post = _resultPosts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPostDetailPage(postId: post['id'], currentUserId: widget.userId),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.grey.shade200,
                    child: (post['image_url'] != null && post['image_url'] != "")
                        ? CachedNetworkImage(imageUrl: post['image_url'], fit: BoxFit.cover)
                        : const Icon(Icons.image, color: Colors.grey),
                  ),
                );
              },
            ),
          ],

          SizedBox(height: 200.h),
        ],
      ),
    );
  }

  Widget _buildList(List data, String emptyMsg, Widget Function(dynamic) itemBuilder) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          style: TextStyle(fontSize: 30.sp, color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      // 🔥 2. TAMBAHKAN PADDING DISINI
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),

      itemCount: data.length,
      itemBuilder: (context, index) => itemBuilder(data[index]),
    );
  }
}
