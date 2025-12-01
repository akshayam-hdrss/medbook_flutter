// ignore_for_file: equal_keys_in_map
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:medbook/components/Events/EventsPage2.dart';
import 'package:medbook/utils/network_connection.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:medbook/components/Charities/CharitiesPage.dart';
import 'package:medbook/components/Contact/contact.dart';
import 'package:medbook/components/Header/Header.dart';
import 'package:medbook/components/Offers/offers.dart';
import 'package:medbook/components/Termsandconditions/Termsandconditions.dart';
import 'package:medbook/pages/blogs/blog.dart';
import 'package:medbook/pages/home_page.dart';
import 'package:medbook/pages/services/service_page.dart';
import 'package:medbook/pages/starting_page.dart';
import 'package:medbook/admin/adminhome_page.dart';
import 'package:medbook/pages/Hospitals/HospitalPage1.dart';
import 'package:medbook/pages/Doctors/Doctors_Page1.dart';
import 'package:medbook/pages/Traditional/Traditional1.dart';
import 'package:medbook/services/secure_storage_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep splash until app finishes loading
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  NetworkConnection.checkInternetConnection();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SecureStorageService _storage = SecureStorageService();
  IO.Socket? socket;

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  /// 🔥 CLEAN – No white screen between splash & app
  Future<void> _initApp() async {
    await _checkAuthStatus(); // Only check login
    FlutterNativeSplash.remove(); // Now remove splash
  }

  Future<bool> _checkAuthStatus() async {
    final token = await _storage.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    setState(() {
      _isLoggedIn = isLoggedIn;
    });

    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedBook',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(scaffoldBackgroundColor: Colors.white),

      // INITIAL SCREEN - no loading widget
      home: _isLoggedIn ? const HomePage() : const StartingPage(),

      routes: {
        '/HomePage': (context) => const HomePage(),
        '/Blogs': (context) => const BlogPage(),
        '/contact': (context) => const Contact(),
        '/offers': (context) => const OffersPage(),
        '/termsandconditions': (context) => const TermsAndConditions(),
        '/services': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;

          final serviceId = args != null && args.containsKey('serviceId')
              ? args['serviceId']
              : '16';

          return ServicePage(serviceId: serviceId);
        },
      },

      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);

        Widget withFooter(Widget page) {
          return Scaffold(
            body: Column(children: [Expanded(child: page)]),
          );
        }

        // Protected Routes
        if (uri.path == '/Hospitals/HospitalPage1' ||
            uri.path == '/Doctors/Doctors_page1' ||
            uri.path == '/Traditional/Traditional1' ||
            uri.path == '/admin') {
          if (_isLoggedIn) {
            switch (uri.path) {
              case '/Hospitals/HospitalPage1':
                return MaterialPageRoute(
                  builder: (_) => withFooter(const HospitalPage1()),
                );
              case '/Doctors/Doctors_page1':
                return MaterialPageRoute(
                  builder: (_) => withFooter(const DoctorsPage1()),
                );
              case '/Traditional/Traditional1':
                return MaterialPageRoute(
                  builder: (_) => withFooter(Traditional1()),
                );
              case '/admin':
                return MaterialPageRoute(
                  builder: (_) => withFooter(const AdminPage()),
                );
            }
          } else {
            return MaterialPageRoute(builder: (_) => const StartingPage());
          }
        }

        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == "events") {
          return MaterialPageRoute(
            builder: (_) => const EventsPage2(),
            settings: settings,
          );
        }
        if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == "charities") {
          return MaterialPageRoute(
            builder: (_) => const CharitiesPage1(),
            settings: settings,
          );
        }

        if (uri.path == '/header') {
          return MaterialPageRoute(builder: (_) => const Header());
        }

        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
      },
      
    );
  }
}
