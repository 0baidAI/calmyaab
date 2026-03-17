import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/landing/landing_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/admin/admin_login_screen.dart';

// Auth guard: redirect to /login if not logged in
String? _authGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/login';
  return null;
}

// Reverse guard: redirect to /dashboard if already logged in
String? _guestGuard(BuildContext context, GoRouterState state) {
  return null;
}

// Admin guard
String? _adminGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/admin-login';
  return null;
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    // ── Public ───────────────────────────────────────────────────────────
    GoRoute(
      path: '/',
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),

    GoRoute(
      path: '/login',
      name: 'login',
      redirect: _guestGuard,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      redirect: _guestGuard,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/admin-login',
      name: 'admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),

    // ── Protected (auth required) ─────────────────────────────────────────
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      redirect: _authGuard,
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/admin',
      name: 'admin',
      redirect: _adminGuard,
      builder: (context, state) => const AdminScreen(),
    ),

  ],
  errorBuilder: (context, state) => const Scaffold(
    backgroundColor: Color(0xFF0A0A0A),
    body: Center(
      child: Text('Page not found', style: TextStyle(color: Colors.white70)),
    ),
  ),
);