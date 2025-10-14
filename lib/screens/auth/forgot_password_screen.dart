import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _shakeController;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _shakeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isLoading = false;
  bool _emailHasError = false;

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

    // Shake animation for errors
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    // Start entrance animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });

    // Add focus listeners for field animations
    _emailFocus.addListener(_onEmailFocusChange);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    setState(() {});
  }

  void _shakeForm() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _sendResetEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      HapticFeedback.mediumImpact();
      _scaleController.forward();

      try {
        // TODO: Implement forgot password API call
        print('📧 Sending reset email to: ${_emailController.text.trim()}');

        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to OTP screen
        Navigator.pushReplacementNamed(context, '/OTPScreen');
      } catch (e) {
        print('💥 Forgot password error: $e');
        HapticFeedback.heavyImpact();
        _shakeForm();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reset email: ${e.toString()}'),
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
      }
    } else {
      _shakeForm();
      HapticFeedback.mediumImpact();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onLeadingPressed: () => Navigator.pop(context),
        leadingIcon: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: const Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

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

                        const SizedBox(height: 20),

                        // Instructions
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.lock_reset,
                                    size: 48,
                                    color: Color(0xFF2F855A),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Reset Your Password',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A202C),
                                      fontFamily: 'Poppins',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Enter your email address and we\'ll send you a code to reset your password.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontFamily: 'Poppins',
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Email Field
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: AnimatedContainer(
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
                                textInputAction: TextInputAction.done,
                                validator: _validateEmail,
                                onFieldSubmitted: (_) => _sendResetEmail(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
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
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF2F855A),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Send Reset Button
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendResetEmail,
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
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'SEND RESET CODE',
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

                        const SizedBox(height: 40),
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
