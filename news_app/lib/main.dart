import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/news_app/presentation/cubit/auth_cubit.dart';
import 'features/news_app/presentation/cubit/news_cubit.dart';

import 'features/news_app/presentation/views/login_screen.dart';
import 'features/news_app/presentation/views/register_screen.dart';
import 'features/news_app/presentation/views/forgot_password_screen.dart';
import 'features/news_app/presentation/views/home_screen.dart';

import 'features/news_app/data/services/local_auth_service.dart';
import 'features/news_app/data/services/news_service.dart';
import 'features/news_app/data/repositories/news_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences before the app starts
  final prefs = await SharedPreferences.getInstance();

  runApp(MainApp(prefs: prefs));
}

class MainApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MainApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Initialize services and repositories once
    final authService = LocalAuthService();
    final newsService = NewsService();
    final newsRepository = NewsRepository(newsService, prefs);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authService),
        ),
        BlocProvider<NewsCubit>(
          create: (_) => NewsCubit(newsRepository),
        ),
      ],
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());

            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());

            case '/forgot':
              return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

            case '/home':
              final args = settings.arguments as Map<String, dynamic>?;

              // Validate required arguments
              if (args == null || args['email'] == null) {
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              }

              return MaterialPageRoute(
                builder: (_) => HomeScreen(
                  email: args['email'] as String,
                  username: args['username'] as String?,
                ),
              );

            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}
