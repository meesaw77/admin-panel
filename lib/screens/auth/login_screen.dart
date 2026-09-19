import 'package:admin/controllers/auth_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/theme/app_icons.dart';
import 'package:admin/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../utils/full_stop_aesthetics.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      if (auth.emailController.text.isEmpty) {
        auth.emailController.text = "admin@example.com";
      }
      if (auth.passwordController.text.isEmpty) {
        auth.passwordController.text = "admin123";
      }
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthController auth) async {
    FocusScope.of(context).unfocus();
    auth.clearErrors();
    await auth.login();
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _buildMobileView();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 20,
                    offset: const Offset(10, 0),
                  ),
                ],
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _buildLoginForm(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryRed.withValues(alpha: 0.08),
                          AppColors.primaryRed.withValues(alpha: 0.02),
                          AppColors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.8,
                    child: SvgPicture.asset(
                      "assets/icons/sig.svg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _buildLoginForm(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, child) {
        return Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: buildLogo()),
                const SizedBox(height: 32),
                const Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.softBlack,
                    letterSpacing: -0.5,
                    fontFamily: 'Libre',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your credentials to manage your account",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 48),

                // ---------------- EMAIL ----------------
                _buildTextFormField(
                  controller: auth.emailController,
                  focusNode: _emailFocus,
                  nextFocus: _passwordFocus,
                  label: "Email Address",
                  hint: "name@example.com",
                  svgIcon: AppIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  onChanged: (_) {
                    auth.clearEmailServerError();
                    auth.clearGeneralError();
                  },
                  validator: (v) {
                    final value = (v ?? "").trim();
                    if (value.isEmpty) return "Email is required";
                    final ok = RegExp(
                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                    ).hasMatch(value);
                    if (!ok) return "Enter a valid email";

                    if (auth.emailServerError != null) {
                      return auth.emailServerError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ---------------- PASSWORD ----------------
                _buildTextFormField(
                  controller: auth.passwordController,
                  focusNode: _passwordFocus,
                  label: "Password",
                  hint: "••••••••",
                  svgIcon: AppIcons.lock,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onToggleVisibility: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onChanged: (_) {
                    auth.clearPasswordServerError();
                    auth.clearGeneralError();
                  },
                  onSubmitted: (_) =>
                      auth.isLoading ? null : _handleLogin(auth),
                  validator: (v) {
                    final value = (v ?? "");
                    if (value.isEmpty) return "Password is required";
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    if (auth.passwordServerError != null) {
                      return auth.passwordServerError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // ---------------- LOGIN BUTTON ----------------
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : () => _handleLogin(auth),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: auth.isLoading
                        ? LoadingAnimationWidget.staggeredDotsWave(
                            color: AppColors.primaryRed,
                            size: 20,
                          )
                        : const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String svgIcon,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    String? Function(String?)? validator,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.softBlack.withValues(alpha: 0.8),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onChanged: onChanged,
          onFieldSubmitted: (v) {
            if (onSubmitted != null) {
              onSubmitted(v);
              return;
            }
            if (nextFocus != null) {
              nextFocus.requestFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.softBlack,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(14),
              child: SvgPicture.asset(
                svgIcon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade400,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    tooltip: obscureText ? "Show password" : "Hide password",
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
