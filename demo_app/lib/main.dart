import 'package:demo_app/screens/login.dart';
import 'package:demo_app/screens/main_layout.dart';
import 'package:demo_app/screens/new_taskpage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/homepage.dart';
import 'package:demo_app/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bypass_login.dart';  // Import from local path since it's in the same directory

// Set to true to bypass Supabase auth for development
const bool DEV_MODE = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Load env
  await dotenv.load();
  //Initialize supabase
  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseKey = dotenv.env['SUPABASE_KEY'] ?? '';
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DEV_MODE ? const DevBypass() : SplashScreen(),
        '/auth': (context) => DEV_MODE ? const DevBypass() : AuthPage(),
        '/login': (context) => DEV_MODE ? const DevBypass() : Login(),
        '/home': (context) => HomePage(),
        '/main': (context) => MainLayout(),
        '/newtask': (context) => NewTaskPage(),
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  User? _user;

  @override
  void initState() {
    _getAuth();
    super.initState();
  }

  Future<void> _getAuth() async {
    setState(() {
      _user = supabase.auth.currentUser;
    });
    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const Login() : MainLayout();
  }
}
