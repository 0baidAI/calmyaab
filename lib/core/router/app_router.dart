import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/landing/landing_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/admin/admin_screen.dart';
import '../../screens/admin/admin_login_screen.dart';
import '../../screens/partner/partner_login_screen.dart';
import '../../screens/partner/partner_register_screen.dart';
import '../../screens/partner/partner_screen.dart';
import '../../screens/agency/agency_login_screen.dart';
import '../../screens/agency/agency_screen.dart';

String? _authGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/login';
  return null;
}

String? _guestGuard(BuildContext context, GoRouterState state) {
  return null;
}

String? _adminGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/admin-login';
  return null;
}

String? _partnerGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/partner-login';
  return null;
}

String? _agencyGuard(BuildContext context, GoRouterState state) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return '/agency-login';
  return null;
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    // ── Public ───────────────────────────────────────────────────────────
    GoRoute(path: '/', name: 'landing',
        builder: (context, state) => const LandingScreen()),

    GoRoute(path: '/login', name: 'login',
        redirect: _guestGuard,
        builder: (context, state) => const LoginScreen()),

    GoRoute(path: '/register', name: 'register',
        redirect: _guestGuard,
        builder: (context, state) => const RegisterScreen()),

    // ── Admin ─────────────────────────────────────────────────────────────
    GoRoute(path: '/admin-login', name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen()),

    GoRoute(path: '/admin', name: 'admin',
        redirect: _adminGuard,
        builder: (context, state) => const AdminScreen()),

    // ── Partner ───────────────────────────────────────────────────────────
    GoRoute(path: '/partner-login', name: 'partner-login',
        builder: (context, state) => const PartnerLoginScreen()),

    GoRoute(path: '/partner-register', name: 'partner-register',
        builder: (context, state) => const PartnerRegisterScreen()),

    GoRoute(path: '/partner', name: 'partner',
        redirect: _partnerGuard,
        builder: (context, state) => const PartnerScreen()),

    // ── Agency ────────────────────────────────────────────────────────────
    GoRoute(path: '/agency-login', name: 'agency-login',
        builder: (context, state) => const AgencyLoginScreen()),

    GoRoute(path: '/agency', name: 'agency',
        redirect: _agencyGuard,
        builder: (context, state) => const AgencyScreen()),

    // ── Student ───────────────────────────────────────────────────────────
    GoRoute(path: '/dashboard', name: 'dashboard',
        redirect: _authGuard,
        builder: (context, state) => const DashboardScreen()),

  ],
  errorBuilder: (context, state) => const Scaffold(
    backgroundColor: Color(0xFF0A0A0A),
    body: Center(child: Text('Page not found',
        style: TextStyle(color: Colors.white70))),
  ),
);