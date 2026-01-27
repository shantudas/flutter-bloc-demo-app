import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injection_container.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/pages/posts_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => BlocProvider(
        create: (context) => sl<SplashBloc>(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (context) => sl<PostsBloc>(),
        child: const PostsScreen(),
      ),
    ),
  ],
);

