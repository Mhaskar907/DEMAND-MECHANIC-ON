import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'role_selection_page.dart';
import 'user_home_page.dart';
import 'user_profile_form.dart';
import 'mechanic_home_page.dart';
import 'mechanic_profile_form.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  String? _lastCheckedUserId;
  bool _checkingProfile = false;
  bool _userHasProfile = false;
  bool _mechanicHasProfile = false;

  Future<void> _checkProfiles(String userId, String role) async {
    // Avoid re-checking if we already checked for this user
    if (_lastCheckedUserId == userId && !_checkingProfile) {
      print('✅ Profile already checked for user: $userId');
      return;
    }

    setState(() {
      _checkingProfile = true;
    });

    try {
      print('🔍 Checking profile for user: $userId, role: $role');
      
      if (role == 'user') {
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        print('📋 User profile result: ${profile != null ? "Found" : "Not found"}');

        if (mounted) {
          setState(() {
            _userHasProfile = profile != null;
            _mechanicHasProfile = false;
            _lastCheckedUserId = userId;
            _checkingProfile = false;
          });
        }
      } else if (role == 'mechanic') {
        final profile = await Supabase.instance.client
            .from('mechanic_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        print('📋 Mechanic profile result: ${profile != null ? "Found" : "Not found"}');

        if (mounted) {
          setState(() {
            _mechanicHasProfile = profile != null;
            _userHasProfile = false;
            _lastCheckedUserId = userId;
            _checkingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _checkingProfile = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error checking profile: $e');
      if (mounted) {
        setState(() {
          _checkingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // If user logged out, reset state
        if (authService.currentUser == null) {
          if (_lastCheckedUserId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _lastCheckedUserId = null;
                  _userHasProfile = false;
                  _mechanicHasProfile = false;
                  _checkingProfile = false;
                });
              }
            });
          }
          return const RoleSelectionPage();
        }

        // User is logged in, check their profile
        final userId = authService.currentUser!.id;
        final role = authService.currentUserRole;

        // Trigger profile check if needed
        if (role != null && _lastCheckedUserId != userId && !_checkingProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkProfiles(userId, role);
          });
        }

        // Show loading while checking profile
        if (authService.isLoading || _checkingProfile) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your profile...'),
                ],
              ),
            ),
          );
        }

        // Route based on role and profile status
        if (role == 'user') {
          if (_userHasProfile) {
            return const UserHomePage();
          } else {
            return const UserProfileForm(isFirstTime: true);
          }
        } else if (role == 'mechanic') {
          if (_mechanicHasProfile) {
            return const MechanicHomePage();
          } else {
            return const MechanicProfileForm(isFirstTime: true);
          }
        } else {
          return const RoleSelectionPage();
        }
      },
    );
  }
}