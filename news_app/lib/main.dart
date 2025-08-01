import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/news_app/presentation/cubit/auth_cubit.dart';
import 'features/news_app/presentation/cubit/news_cubit.dart';

import 'features/news_app/presentation/views/login_screen.dart';
import 'features/news_app/presentation/views/register_screen.dart';
import 'features/news_app/presentation/views/forgot_password_screen.dart';
import 'features/news_app/presentation/views/home_screen.dart';
import 'features/news_app/presentation/views/settings_screen.dart';
import 'features/news_app/presentation/views/profile_screen.dart';

import 'features/news_app/data/services/local_auth_service.dart';
import 'features/news_app/data/services/news_service.dart';
import 'features/news_app/data/repositories/news_repository.dart';
import 'features/news_app/data/models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final authService = LocalAuthService();
    final newsService = NewsService();
    final newsRepository = NewsRepository(newsService, prefs);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authService)),
        BlocProvider(create: (_) => NewsCubit(newsRepository)),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    final args = settings.arguments;

    switch (name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case '/forgot':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case '/home':
        if (args is Map<String, dynamic>) {
          final id = args['id'] as String? ?? '1';
          final firstName = args['firstName'] as String? ?? '';
          final lastName = args['lastName'] as String? ?? '';
          final email = args['email'] as String?;
          final passwordHash = args['passwordHash'] as String? ?? '';

          if (email?.isNotEmpty == true && passwordHash.isNotEmpty) {
            final user = User(
              id: id,
              firstName: firstName,
              lastName: lastName,
              email: email!,
              passwordHash: passwordHash,
            );

            return MaterialPageRoute(builder: (_) => HomeScreen(user: user));
          }
        }
        return MaterialPageRoute(builder: (_) => const HomeScreenLoader());

      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/bookmarks':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Bookmarks')),
            body: const Center(child: Text('Bookmarks Screen Placeholder')),
          ),
        );

      default:
        debugPrint('Unknown route: $name');
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}

class HomeScreenLoader extends StatefulWidget {
  const HomeScreenLoader({super.key});

  @override
  State<HomeScreenLoader> createState() => _HomeScreenLoaderState();
}

class _HomeScreenLoaderState extends State<HomeScreenLoader> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id') ?? '1';
    final firstName = prefs.getString('firstName') ?? '';
    final lastName = prefs.getString('lastName') ?? '';
    final email = prefs.getString('registeredEmail') ?? '';
    final passwordHash = prefs.getString('passwordHash') ?? '';

    if (email.isNotEmpty && passwordHash.isNotEmpty) {
      user = User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        passwordHash: passwordHash,
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      // No user info, navigate to login screen and remove this page from stack
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const SizedBox.shrink();
    }

    // User found, show home screen
    return HomeScreen(user: user!);
  }
}
