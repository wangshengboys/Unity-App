import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_page.dart';
import 'screens/main_screen.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // --- CEK SESI LOGIN DI LOKAL STORAGE ---
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt('user_id');
  String? savedUsername = prefs.getString('username');
  String? savedDisplayName = prefs.getString('display_name');

  Widget initialScreen = const LoginPage();
  if (savedUserId != null && savedUsername != null) {
    // Jika sudah pernah login, langsung tembak ke MainScreen
    initialScreen = MainScreen(
      userId: savedUserId,
      username: savedDisplayName ?? savedUsername, 
    );
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 2424),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Sosmed App',

          theme: ThemeData(
            fontFamily: 'SFPro',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),

          // Initial Screen Dinamis (Berdasarkan sesi login)
          home: initialScreen,

          // Main Page user
          //home: const MainScreen(username: "centaury (Dev)", userId: 1),
          //home: const MainScreen(username: "bintang_timur (Dev)", userId: 2),
          //home: const MainScreen(username: "photoshop (Dev)", userId: 3),
          //home: const MainScreen(username: "illustrator (Dev)", userId: 5),

          //Profile Page
          //home: ProfilePage(userId: 1),

          //Admin Page
          //home: const DevLauncherPage(),
        );
      },
    );
  }
}

class DevLauncherPage extends StatelessWidget {
  const DevLauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "PROJECT LAUNCHER",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              },
              icon: const Icon(Icons.smartphone),
              label: const Text("BUKA APLIKASI UTAMA"),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("BUKA ADMIN DASHBOARD"),
            ),
          ],
        ),
      ),
    );
  }
}
