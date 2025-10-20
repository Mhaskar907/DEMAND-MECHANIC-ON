import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'theme/app_theme.dart';
import 'utils/dimensions.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dim = Dimensions(context);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(dim.width20),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo and Title Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: dim.height45 * 2.5,
                          height: dim.height45 * 2.5,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(dim.radius30),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.build_circle,
                            size: dim.height45 + dim.height15,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: dim.height30),
                        Text(
                          'MechanicConnect',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontSize: dim.font26 * 1.2,
                          ),
                        ),
                        SizedBox(height: dim.height15),
                        Text(
                          'Connect with trusted mechanics\nor start your service business',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                            fontSize: dim.font16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Role Selection Cards
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildRoleCard(
                          context,
                          dim,
                          icon: Icons.person,
                          title: 'I Need Service',
                          subtitle: 'Find trusted mechanics\nfor your vehicle',
                          gradient: AppTheme.primaryGradient,
                          onTap: () => _navigateToLogin('user'),
                        ),
                        SizedBox(height: dim.height20),
                        _buildRoleCard(
                          context,
                          dim,
                          icon: Icons.build,
                          title: 'I Provide Service',
                          subtitle: 'Start earning by helping\nothers with their vehicles',
                          gradient: AppTheme.secondaryGradient,
                          onTap: () => _navigateToLogin('mechanic'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Sign Up Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'New to MechanicConnect?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: dim.font16,
                        ),
                      ),
                      SizedBox(height: dim.height10),
                      TextButton(
                        onPressed: () => _navigateToSignup(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          textStyle: TextStyle(
                            fontSize: dim.font16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: dim.height20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    Dimensions dim, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: dim.height45 * 3,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(dim.radius20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dim.radius20),
          child: Padding(
            padding: EdgeInsets.all(dim.width20),
            child: Row(
              children: [
                Container(
                  width: dim.height45 + dim.height15,
                  height: dim.height45 + dim.height15,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(dim.radius15),
                  ),
                  child: Icon(
                    icon,
                    size: dim.iconSize24 + dim.height10,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: dim.width20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: dim.font20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: dim.height10 / 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: dim.font16,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: dim.iconSize24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLogin(String role) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginPage(role: role),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }
}