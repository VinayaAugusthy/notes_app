import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/core/extensions/media_query_extensions.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:notes_app/presentation/auth/auth_view_model.dart';
import 'package:notes_app/presentation/auth/signup_view.dart';
import 'package:notes_app/presentation/widgets/app_button.dart';
import 'package:notes_app/presentation/widgets/app_loader.dart';
import 'package:notes_app/presentation/widgets/app_text_form_field.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final loginFormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (loginFormKey.currentState?.validate() ?? false) {
      final authViewModel = ref.read(authProvider);
      final success = await authViewModel.signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      if (!success && mounted) {
        final errorMessage = authViewModel.errorMessage;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && errorMessage != null) {
            AppSnackbar.showError(context, errorMessage);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = ref.watch(authProvider);
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: EdgeInsets.all(context.screenWidth / 16),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.login,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.red,
                        ),
                      ),
                      SizedBox(height: context.screenHeight / 18),
                      AppTextFormField(
                        controller: emailController,
                        hintText: AppStrings.enterEmail,
                        errorMsg: AppStrings.emailRequired,
                      ),
                      SizedBox(height: 30),
                      AppTextFormField(
                        controller: passwordController,
                        hintText: AppStrings.enterPassword,
                        errorMsg: AppStrings.passwordRequired,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: context.screenWidth,
                        child: authVM.isLoading
                            ? AppLoader()
                            : AppButton(
                                buttonText: AppStrings.login,
                                onPressed: _handleLogin,
                              ),
                      ),

                      SizedBox(height: 30),
                      RichText(
                        text: TextSpan(
                          text: AppStrings.dontHaveAccount,
                          style: TextStyle(color: AppColors.black),
                          children: [
                            TextSpan(
                              text: AppStrings.signUp,
                              style: TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupView(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
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
