import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth/login_page.dart';
import 'screens/main_screen.dart';

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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt('user_id');
  String? savedUsername = prefs.getString('username');
  String? savedDisplayName = prefs.getString('display_name');

  Widget initialScreen = const LoginPage();
  if (savedUserId != null && savedUsername != null) {
    initialScreen = MainScreen(
      userId: savedUserId,
      username: savedDisplayName ?? savedUsername,
    );
  }

  runApp(ProviderScope(child: MyApp(initialScreen: initialScreen)));
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
