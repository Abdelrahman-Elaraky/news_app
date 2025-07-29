import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/news_app/presentation/cubit/auth_cubit.dart';
import 'features/news_app/presentation/views/login_screen.dart';
import 'features/news_app/presentation/views/register_screen.dart';
import 'features/news_app/presentation/views/forgot_password_screen.dart';
import 'features/news_app/data/services/local_auth_service.dart'; // import your service

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Pass an instance of LocalAuthService to AuthCubit constructor
      create: (_) => AuthCubit(LocalAuthService()),
      child: MaterialApp(
        title: 'News App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot': (context) => const ForgotPasswordScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
