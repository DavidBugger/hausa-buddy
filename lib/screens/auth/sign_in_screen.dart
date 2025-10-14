import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../services/biometric_service.dart';
import '../../models/user.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController; // Fade animation for title and form
  late AnimationController _slideController; // Slide animation for title and form
  late AnimationController _scaleController; // Scale animation for button
  late AnimationController _shakeController; // Shake animation for form
  late AnimationController _loadingController; // Loading animation for button

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _signUpFadeAnimation;
  late Animation<Offset> _shakeAnimation;
  late Animation<double> _loadingRotateAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _emailHasError = false;
  bool _passwordHasError = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Title animations
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));

    // Form animations
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    ));

    // Button animations
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Sign up animations
    _signUpFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Shake animation for errors
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Loading animation
    _loadingRotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    // Start entrance animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });

    // Load saved credentials
    _loadSavedCredentials();

    // Add focus listeners for field animations
    _emailFocus.addListener(_onEmailFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _loadingController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onPasswordFocusChange() {
    setState(() {});
  }

  void _onEmailFocusChange() {
    setState(() {});
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final credentials = await authProvider.getSavedCredentials();

      if (credentials['email'] != null && credentials['password'] != null) {
        setState(() {
          _emailController.text = credentials['email']!;
          _passwordController.text = credentials['password']!;
        });
        print('✅ Loaded saved credentials');
      }
    } catch (e) {
      print('⚠️ Failed to load saved credentials: $e');
    }
  }

  void _shakeForm() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      HapticFeedback.mediumImpact();
      _scaleController.forward();
      _loadingController.repeat();

      try {
        // Use AuthProvider for login
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        print('🔐 Starting login process...');
        print('📧 Email: ${_emailController.text.trim()}');

        final success = await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (success) {
          print('🎉 Login successful!');
          HapticFeedback.mediumImpact();
          // Navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Show error message when login fails
          _shakeForm();
          print('❌ Login failed - check console for details');

          // Show error message from AuthProvider
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final errorMessage = authProvider.error ?? 'Login failed. Please check your credentials.';

          print('📱 Showing error to user: $errorMessage');

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } catch (e) {
        print('💥 SignIn screen exception: $e');
        HapticFeedback.heavyImpact();
        _shakeForm();

        // Show error message from AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final errorMessage = authProvider.error ?? 'Sign in failed: ${e.toString()}';

        print('📱 Showing error to user: $errorMessage');

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });

        _scaleController.reverse();
        _loadingController.stop();
        _loadingController.reset();
      }
    } else {
      _shakeForm();
      HapticFeedback.mediumImpact();
    }
  }

  void _navigateToSignUp() {
    HapticFeedback.lightImpact();
    // Navigator.pushNamed(context, '/signup');
    Navigator.pushReplacementNamed(context, '/SignUpScreen'); // Use '/SignInScreen'

    print('Navigate to Sign Up');
  }

  void _navigateToForgotPassword() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ForgotPasswordScreen');
    print('Navigate to Forgot Password');
  }

  Future<void> _signInWithBiometrics() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();
    _scaleController.forward();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if biometrics are available first
      final bool isAvailable = await authProvider.isBiometricLoginAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication is not available');
      }

      // Get biometric type name for UI feedback
      final String biometricType = await authProvider.getBiometricTypeName();
      print('🔐 Starting biometric authentication with $biometricType...');

      // Perform actual biometric authentication with proper context
      final biometricService = BiometricService();
      final bool didAuthenticate = await biometricService.authenticate(
        reason: 'Authenticate with $biometricType to access Learn Hausa',
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
      );

      if (didAuthenticate) {
        print('🎉 Biometric authentication successful!');

        // Check if there's a cached user session
        final bool hasValidSession = await authProvider.hasCachedUserSessionAsync();
        if (hasValidSession) {
          // Get cached user and restore session
          final User? cachedUser = authProvider.getUserFromCache();
          if (cachedUser != null) {
            print('🔄 Restoring cached user session...');
            // Set user in provider
            await authProvider.restoreUserSession(cachedUser);

            HapticFeedback.mediumImpact();
            // Navigate to home screen
            Navigator.pushReplacementNamed(context, '/home');
            return;
          }
        }

        // No cached session found
        print('❌ No cached user session found');
        _showBiometricError('Please sign in with your email and password first to enable biometric authentication');
      } else {
        print('❌ Biometric authentication failed or cancelled');
        _showBiometricError('Biometric authentication was cancelled or failed');
      }
    } on BiometricException catch (e) {
      print('💥 Biometric exception: ${e.message}');
      _showBiometricError(e.message);
    } catch (e) {
      print('💥 Biometric authentication error: $e');
      _showBiometricError('Biometric authentication failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });

      _scaleController.reverse();
    }
  }

  void _showBiometricError(String message) {
    HapticFeedback.heavyImpact();
    _shakeForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _emailHasError = true);
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() => _emailHasError = true);
      return 'Please enter a valid email';
    }
    setState(() => _emailHasError = false);
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      setState(() => _passwordHasError = true);
      return 'Please enter your password';
    }
    if (value.length < 6) {
      setState(() => _passwordHasError = true);
      return 'Password must be at least 6 characters';
    }
    setState(() => _passwordHasError = false);
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // title: 'Sign In',
        onLeadingPressed: () => Navigator.pop(context),
        leadingIcon: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: const Color(0xFF1A202C)),
            onPressed: _navigateToSignUp,
      ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Color(0xFFFFFFFF), // white
            ],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _shakeAnimation,
            child: SingleChildScrollView(  // Make content scrollable
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100, // Ensure minimum height
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40), // Top spacing instead of Spacer

                        // App Title
                        SlideTransition(
                          position: _titleSlideAnimation,
                          child: FadeTransition(
                            opacity: _titleFadeAnimation,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Learn',
                                    style: TextStyle(color: Color(0xFF1A202C)),
                                  ),
                                  TextSpan(
                                    text: ' Hausa',
                                    style: TextStyle(color: Color(0xFF2F855A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20), // Space instead of Spacer

                        // Form Fields
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: Column(
                              children: [
                                // Email Field
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _emailFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2F855A).withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: _validateEmail,
                                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Poppins',
                                      ),
                                      filled: true,
                                      fillColor: _emailFocus.hasFocus
                                          ? Colors.white
                                          : const Color(0xFFF7FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: _emailHasError
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2F855A),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: _passwordFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF2F855A).withOpacity(0.2),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    obscureText: !_isPasswordVisible,
                                    textInputAction: TextInputAction.done,
                                    validator: _validatePassword,
                                    onFieldSubmitted: (_) => _signIn(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[500],
                                        fontFamily: 'Poppins',
                                      ),
                                      filled: true,
                                      fillColor: _passwordFocus.hasFocus
                                          ? Colors.white
                                          : const Color(0xFFF7FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: _passwordHasError
                                              ? Colors.red.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF2F855A),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 16,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            key: ValueKey(_isPasswordVisible),
                                            color: const Color(0xFF2F855A),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible = !_isPasswordVisible;
                                          });
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32), // Reduced spacing

                        // Sign In Button
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _signIn,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 8,
                                    shadowColor: const Color(0xFF2F855A).withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ).copyWith(
                                    backgroundColor: MaterialStateProperty.resolveWith(
                                          (states) {
                                        if (states.contains(MaterialState.disabled)) {
                                          return Colors.grey[400];
                                        }
                                        return const Color(0xFF2F855A);
                                      },
                                    ),
                                  ),
                                  child: _isLoading
                                      ? AnimatedBuilder(
                                          animation: _loadingRotateAnimation,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _loadingRotateAnimation.value * 2 * 3.14159,
                                              child: const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : const Text(
                                          'SIGN IN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20), // Reduced bottom spacing

                        // Biometric Authentication Icon
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return FutureBuilder<bool>(
                              future: authProvider.isBiometricLoginAvailable(),
                              builder: (context, snapshot) {
                                final bool isBiometricAvailable = snapshot.data ?? false;

                                if (!isBiometricAvailable) {
                                  return const SizedBox.shrink();
                                }

                                return FadeTransition(
                                  opacity: _signUpFadeAnimation,
                                  child: Column(
                                    children: [
                                      // Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.grey.withOpacity(0.3),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              'OR',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 1,
                                              color: Colors.grey.withOpacity(0.3),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 32),

                                      // Check if user has logged in before
                                      FutureBuilder<bool>(
                                        future: authProvider.hasCachedUserSession(),
                                        builder: (context, snapshot) {
                                          final bool hasSession = snapshot.data ?? false;
                                          return !hasSession
                                              ? Container(
                                                  margin: const EdgeInsets.only(bottom: 24),
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEF3C7), // Light yellow background
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: const Color(0xFFF59E0B), // Yellow border
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline,
                                                        color: const Color(0xFD9731), // Orange icon
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Sign in with email and password first to enable biometric authentication',
                                                          style: TextStyle(
                                                            color: Colors.grey[800],
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: 'Poppins',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox.shrink();
                                        },
                                      ),

                                      Center(
                                        child: FutureBuilder<String>(
                                          future: authProvider.getBiometricTypeName(),
                                          builder: (context, snapshot) {
                                            final String biometricType = snapshot.data ?? 'Biometric';

                                            return FutureBuilder<bool>(
                                              future: authProvider.hasCachedUserSession(),
                                              builder: (context, sessionSnapshot) {
                                                final bool hasSession = sessionSnapshot.data ?? false;

                                                return GestureDetector(
                                                  onTap: hasSession && !(_isLoading ?? false)
                                                      ? _signInWithBiometrics
                                                      : null,
                                                  child: Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: hasSession
                                                          ? const Color(0xFFF6AD55) // Purple for enabled
                                                          : Colors.grey[200], // Grey for disabled
                                                      boxShadow: hasSession
                                                          ? [
                                                              BoxShadow(
                                                                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                                                blurRadius: 12,
                                                                offset: const Offset(0, 4),
                                                              )
                                                            ]
                                                          : [],
                                                    ),
                                                    child: Icon(
                                                      biometricType.contains('Face')
                                                          ? Icons.face
                                                          : Icons.fingerprint,
                                                      size: 40,
                                                      color: hasSession
                                                          ? Colors.white
                                                          : Colors.grey[400],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Biometric Text
                                      FutureBuilder<String>(
                                        future: authProvider.getBiometricTypeName(),
                                        builder: (context, snapshot) {
                                          final String biometricType = snapshot.data ?? 'Biometric';

                                          return FutureBuilder<bool>(
                                            future: authProvider.hasCachedUserSession(),
                                            builder: (context, sessionSnapshot) {
                                              final bool hasSession = sessionSnapshot.data ?? false;

                                              return Text(
                                                hasSession
                                                    ? 'Tap to sign in with $biometricType'
                                                    : 'Biometric Login',
                                                style: TextStyle(
                                                  color: hasSession
                                                      ? const Color(0xFFF6AD55)
                                                      : Colors.grey[500],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        // Forgot Password Link
                        FadeTransition(
                          opacity: _signUpFadeAnimation,
                          child: Center(
                            child: TextButton(
                              onPressed: _navigateToForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF2F855A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Sign In Link
                        FadeTransition(
                          opacity: _signUpFadeAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextButton(
                                onPressed: _navigateToSignUp,
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFFF6AD55),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}