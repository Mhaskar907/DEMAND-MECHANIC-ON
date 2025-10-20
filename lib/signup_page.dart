import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'utils/dimensions.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'user';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(dim.width20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: dim.height30),
                    // Header Section
                    _buildHeader(dim),
                    SizedBox(height: dim.height30),
                    // Signup Form
                    _buildSignupForm(dim),
                    SizedBox(height: dim.height30),
                    _buildOrDivider(dim),
                    SizedBox(height: dim.height15),
                    _buildGoogleButton(dim),
                    SizedBox(height: dim.height30),
                    // Login Link
                    _buildLoginLink(dim),
                    SizedBox(height: dim.height20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider(Dimensions dim) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: dim.width10),
          child: const Text('OR'),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildGoogleButton(Dimensions dim) {
    return SizedBox(
      height: dim.height45 + dim.height10,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _signUpWithGoogle,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dim.radius15),
          ),
        ),
        icon: Image.asset(
          'assets/google.png',
          width: dim.iconSize24,
          height: dim.iconSize24,
          errorBuilder: (_, __, ___) => Icon(Icons.login, size: dim.iconSize16),
        ),
        label: Text(
          'Continue with Google',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: dim.font16),
        ),
      ),
    );
  }

  Widget _buildHeader(Dimensions dim) {
    return Column(
      children: [
        // Back Button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.all(dim.height10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(dim.radius15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.textPrimary,
                size: dim.iconSize24,
              ),
            ),
          ),
        ),
        SizedBox(height: dim.height30),
        // App Icon
        Container(
          width: dim.height45 + dim.height30,
          height: dim.height45 + dim.height30,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(dim.radius20),
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
            size: dim.iconSize24 * 1.5,
            color: Colors.white,
          ),
        ),
        SizedBox(height: dim.height20),
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: dim.font26,
          ),
        ),
        SizedBox(height: dim.height10),
        Text(
          'Join MechanicConnect today',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: dim.font16,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm(Dimensions dim) {
    return Container(
      padding: EdgeInsets.all(dim.width20),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Selection
            _buildRoleSelection(dim),
            SizedBox(height: dim.height20),
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: dim.font16),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(fontSize: dim.font16),
                hintText: 'Enter your email',
                hintStyle: TextStyle(fontSize: dim.font16),
                prefixIcon: Icon(Icons.email_outlined, size: dim.iconSize24),
                suffixIcon: _emailController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: dim.iconSize24),
                        onPressed: () {
                          _emailController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: dim.height20),
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(fontSize: dim.font16),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontSize: dim.font16),
                hintText: 'Enter your password',
                hintStyle: TextStyle(fontSize: dim.font16),
                prefixIcon: Icon(Icons.lock_outline, size: dim.iconSize24),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    size: dim.iconSize24,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: dim.height20),
            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: TextStyle(fontSize: dim.font16),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(fontSize: dim.font16),
                hintText: 'Confirm your password',
                hintStyle: TextStyle(fontSize: dim.font16),
                prefixIcon: Icon(Icons.lock_outline, size: dim.iconSize24),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    size: dim.iconSize24,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: dim.height20),
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(dim.height10),
                margin: EdgeInsets.only(bottom: dim.height15),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(dim.radius15 / 2),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: dim.iconSize24,
                    ),
                    SizedBox(width: dim.width10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: dim.font16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Signup Button
            SizedBox(
              height: dim.height45 + dim.height10,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == 'user' 
                      ? AppTheme.primaryColor 
                      : AppTheme.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(dim.radius15),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: dim.iconSize24,
                        height: dim.iconSize24,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: dim.font16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection(Dimensions dim) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I want to:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: dim.font16,
          ),
        ),
        SizedBox(height: dim.height10),
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                dim,
                'user',
                'Find Service',
                Icons.person,
                AppTheme.primaryGradient,
              ),
            ),
            SizedBox(width: dim.width10),
            Expanded(
              child: _buildRoleOption(
                dim,
                'mechanic',
                'Provide Service',
                Icons.build,
                AppTheme.secondaryGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption(Dimensions dim, String role, String title, IconData icon, LinearGradient gradient) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(dim.height15),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(dim.radius15),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: dim.iconSize24,
            ),
            SizedBox(height: dim.height10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontSize: dim.font16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(Dimensions dim) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: dim.font16,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Sign In', style: TextStyle(fontSize: dim.font16)),
        ),
      ],
    );
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final error = await authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );

      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });

      if (error == null) {
        // Navigation is handled by the App widget based on auth state
        // User is automatically logged in after signup
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signInWithGoogle(role: _selectedRole);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });
  }

}