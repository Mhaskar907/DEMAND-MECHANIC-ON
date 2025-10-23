import 'package:flutter/material.dart';
import 'package:pro_v1/user_notifications_page.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'user_profile_form.dart';
import 'find_mechanics_page.dart';
import 'user_service_history_page.dart';
import 'user_my_requests_page.dart';
import 'user_ratings_page.dart';
import 'theme/app_theme.dart';
import 'user_chatbot_page.dart';
import 'utils/dimensions.dart';
import 'debug_test_page.dart';
import 'live_location_map_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
    final authService = Provider.of<AuthService>(context);
    final dim = Dimensions(context);

    return Scaffold(
      floatingActionButton: _buildChatFab(context, dim),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  _buildSliverAppBar(context, authService, dim),
                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(dim.width24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          _buildWelcomeSection(context, authService, dim),
                          SizedBox(height: dim.height32),
                          // Quick Actions
                          _buildQuickActions(context, dim),
                          SizedBox(height: dim.height32),
                          // Dashboard Cards
                          _buildDashboardGrid(context, dim),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatFab(BuildContext context, Dimensions dim) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserChatbotPage(),
          ),
        );
      },
      icon: Icon(Icons.chat_bubble_outline, size: dim.iconSize24),
      label: Text('Quick Help', style: TextStyle(fontSize: dim.font16)),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthService authService, Dimensions dim) {
    return SliverAppBar(
      expandedHeight: dim.height120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(dim.radius30),
              bottomRight: Radius.circular(dim.radius30),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: dim.width24, vertical: dim.height16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Good ${_getGreeting()}!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: dim.font16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: dim.height5),
                        Text(
                          'Ready to find help?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: dim.font20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        dim,
                        Icons.bug_report,
                        () => _navigateToDebugTest(context),
                      ),
                      SizedBox(width: dim.width12),
                      _buildActionButton(
                        dim,
                        Icons.notifications_outlined,
                        () => _navigateToNotifications(context),
                      ),
                      SizedBox(width: dim.width12),
                      _buildActionButton(
                        dim,
                        Icons.person_outline,
                        () => _navigateToProfile(context),
                      ),
                      SizedBox(width: dim.width12),
                      _buildActionButton(
                        dim,
                        Icons.logout,
                        () => _showLogoutDialog(context, authService),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(Dimensions dim, IconData icon, VoidCallback onTap) {
    return Container(
      width: dim.height45,
      height: dim.height45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(dim.radius12),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: Colors.white,
          size: dim.iconSize24,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AuthService authService, Dimensions dim) {
    return Container(
      padding: EdgeInsets.all(dim.width24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(dim.radius20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: dim.height60,
            height: dim.height60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(dim.radius16),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: dim.iconSize24 + dim.height10,
            ),
          ),
          SizedBox(width: dim.width16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 11, 11, 11),
                    fontSize: dim.font20,
                  ),
                ),
                SizedBox(height: dim.height5),
                Text(
                  authService.currentUser?.email ?? 'User',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color.fromARGB(255, 24, 24, 24),
                    fontSize: dim.font16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Dimensions dim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: dim.font22,
          ),
        ),
        SizedBox(height: dim.height16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                dim,
                'Find Mechanics',
                Icons.search,
                AppTheme.primaryGradient,
                () => _navigateToFindMechanics(context),
              ),
            ),
            SizedBox(width: dim.width16),
            Expanded(
              child: _buildQuickActionCard(
                context,
                dim,
                'Live Map',
                Icons.map,
                const LinearGradient(
                  colors: [Colors.green, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                () => _navigateToLiveMap(context),
              ),
            ),
          ],
        ),
        SizedBox(height: dim.height16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                dim,
                'Emergency',
                Icons.emergency,
                AppTheme.primaryGradient,
                () => _showEmergencyDialog(context),
              ),
            ),
            SizedBox(width: dim.width16),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    Dimensions dim,
    String title,
    IconData icon,
    LinearGradient gradient,
    VoidCallback onTap,
  ) {
    return Container(
      height: dim.height100,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(dim.radius16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dim.radius16),
          child: Padding(
            padding: EdgeInsets.all(dim.width16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: dim.iconSize24 + dim.height5,
                ),
                SizedBox(height: dim.height8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: dim.font14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, Dimensions dim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: dim.font22,
          ),
        ),
        SizedBox(height: dim.height16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: dim.width16,
          mainAxisSpacing: dim.height16,
          childAspectRatio: 1.2,
          children: [
            _buildDashboardCard(
              context,
              dim,
              Icons.history,
              'Service History',
              'View past services',
              Icons.history,
              const Color.fromARGB(255, 242, 242, 242),
              () => _navigateToServiceHistory(context),
            ),
            _buildDashboardCard(
              context,
              dim,
              Icons.request_page,
              'My Requests',
              'Track your requests',
              Icons.request_page,
              const Color.fromARGB(255, 249, 250, 254),
              () => _navigateToMyRequests(context),
            ),
            // _buildDashboardCard(
            //   context,
            //   dim,
            //   Icons.star,
            //   'Ratings',
            //   'Rate mechanics',
            //   Icons.star,
            //   const Color.fromARGB(255, 250, 251, 252),
            //   () => _navigateToRatings(context),
            // ),
            _buildDashboardCard(
              context,
              dim,
              Icons.person,
              'My Profile',
              'View and edit profile',
              Icons.person,
              const Color.fromARGB(255, 245, 246, 249),
              () => _navigateToProfile(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    Dimensions dim,
    IconData icon,
    String title,
    String subtitle,
    IconData cardIcon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(dim.radius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(dim.radius16),
          child: Padding(
            padding: EdgeInsets.all(dim.width16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: dim.height40,
                  height: dim.height40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(dim.radius10),
                  ),
                  child: Icon(
                    cardIcon,
                    color: color,
                    size: dim.iconSize24,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontSize: dim.font16,
                  ),
                ),
                SizedBox(height: dim.height5),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: dim.font12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _navigateToDebugTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DebugTestPage(),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserNotificationsPage(),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfileForm(isFirstTime: false),
      ),
    );
  }

  void _navigateToLiveMap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveLocationMapPage(),
      ),
    );
  }

  void _navigateToFindMechanics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FindMechanicsPage(),
      ),
    );
  }

  void _navigateToServiceHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserServiceHistoryPage(),
      ),
    );
  }

  void _navigateToMyRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserMyRequestsPage(),
      ),
    );
  }

  void _navigateToRatings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserRatingsPage(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await authService.signOut();
              // Navigate to login and clear all routes
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Service'),
        content: const Text('This feature will connect you with emergency mechanics in your area.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Emergency Service');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
