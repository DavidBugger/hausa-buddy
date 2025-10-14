import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_app_bar.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
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
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();

  bool _isLoading = false;

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
    _otpFocus.addListener(_onOTPFocusChange);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _shakeController.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _onOTPFocusChange() {
    setState(() {});
  }

  void _shakeForm() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      HapticFeedback.mediumImpact();
      _scaleController.forward();

      try {
        // TODO: Implement OTP verification API call
        print('🔐 Verifying OTP: ${_otpController.text.trim()}');

        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Navigate to reset password screen
        Navigator.pushReplacementNamed(context, '/ResetPasswordScreen');
      } catch (e) {
        print('💥 OTP verification error: $e');
        HapticFeedback.heavyImpact();
        _shakeForm();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP code. Please try again.'),
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

  String? _validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP code';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
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
                                    Icons.lock_clock,
                                    size: 48,
                                    color: Color(0xFF2F855A),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Enter Verification Code',
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
                                    'We\'ve sent a 6-digit code to your email address. Please enter it below.',
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

                        // OTP Input Field
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _otpFocus.hasFocus
                                      ? [
                                          const Color(0xFFF0FDF4), // green-50
                                          Colors.white,
                                        ]
                                      : [
                                          const Color(0xFFF7FAFC), // gray-50
                                          Colors.white,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _otpFocus.hasFocus
                                      ? const Color(0xFF2F855A)
                                      : Colors.grey.withOpacity(0.3),
                                  width: _otpFocus.hasFocus ? 3 : 2,
                                ),
                                boxShadow: _otpFocus.hasFocus
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF2F855A).withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF2F855A).withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                children: [
                                  // OTP Label
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _otpFocus.hasFocus
                                              ? const Color(0xFF2F855A).withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.security,
                                              size: 16,
                                              color: _otpFocus.hasFocus
                                                  ? const Color(0xFF2F855A)
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Enter 6-digit code',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _otpFocus.hasFocus
                                                    ? const Color(0xFF2F855A)
                                                    : Colors.grey[600],
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // OTP Input
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 300),
                                    child: TextFormField(
                                      controller: _otpController,
                                      focusNode: _otpFocus,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      validator: _validateOTP,
                                      maxLength: 6,
                                      onFieldSubmitted: (_) => _verifyOTP(),
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 12,
                                        color: Color(0xFF1A202C),
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        hintText: '000000',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          letterSpacing: 12,
                                        ),
                                        counterText: '',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Progress Indicator
                                  Container(
                                    height: 3,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: AnimatedBuilder(
                                      animation: Listenable.merge([_otpController]),
                                      builder: (context, child) {
                                        final progress = (_otpController.text.length / 6).clamp(0.0, 1.0);
                                        return FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: progress,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF2F855A),
                                                  Color(0xFF16A34A),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend Code
                        FadeTransition(
                          opacity: _formFadeAnimation,
                          child: TextButton(
                            onPressed: _isLoading ? null : () {
                              // TODO: Implement resend OTP
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Code resent to your email'),
                                  backgroundColor: const Color(0xFF2F855A),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Didn\'t receive the code? Resend',
                              style: TextStyle(
                                color: Color(0xFF2F855A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Verify Button
                        SlideTransition(
                          position: _formSlideAnimation,
                          child: FadeTransition(
                            opacity: _formFadeAnimation,
                            child: ScaleTransition(
                              scale: _buttonScaleAnimation,
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOTP,
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
                                          'VERIFY CODE',
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
