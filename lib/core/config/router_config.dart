import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/inscription/domain/entities/inscription_entity.dart';
import '../../features/inscription/domain/entities/session_formation_entity.dart';
import '../../features/inscription/presentation/screens/confirmed_screen.dart';
import '../../features/inscription/presentation/screens/inscription_form_screen.dart';
import '../../features/inscription/presentation/screens/mon_espace_screen.dart';
import '../../features/inscription/presentation/screens/splash_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_login_screen.dart';
import '../../features/admin/presentation/screens/dossier_detail_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/inscription',
        name: 'inscription',
        builder: (context, state) => const InscriptionFormScreen(),
      ),
      GoRoute(
        path: '/confirmed',
        name: 'confirmed',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ConfirmedScreen(
            inscription: data['inscription'] as InscriptionEntity,
            session: data['session'] as SessionFormationEntity,
          );
        },
      ),
      GoRoute(
        path: '/mon-espace',
        name: 'mon-espace',
        builder: (context, state) => const MonEspaceScreen(),
      ),
      // Admin routes
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        redirect: (context, state) async {
          final session = Supabase.instance.client.auth.currentSession;
          if (session == null) return '/admin/login';
          return null;
        },
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/dossier/:id',
        name: 'admin-dossier',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DossierDetailScreen(inscriptionId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: Center(
        child: Text(
          'Page non trouvée',
          style: TextStyle(color: const Color(0xFF00FF88)),
        ),
      ),
    ),
  );
}
