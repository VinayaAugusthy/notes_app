import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/core/constants/app_colors.dart';
import 'package:notes_app/core/constants/app_strings.dart';
import 'package:notes_app/core/extensions/media_query_extensions.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:notes_app/presentation/auth/auth_view_model.dart';
import 'package:notes_app/presentation/notes/notes_view.dart';
import 'package:notes_app/presentation/widgets/app_button.dart';
import 'package:notes_app/presentation/widgets/app_loader.dart';
import 'package:notes_app/presentation/widgets/app_text_form_field.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final signUpFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (signUpFormKey.currentState?.validate() ?? false) {
      final authViewModel = ref.read(authProvider);
      final success = await authViewModel.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotesView()),
        );
      } else if (!success && mounted) {
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
      body: Padding(
        padding: EdgeInsets.all(context.screenWidth / 16),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: signUpFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.signUp,
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
                      isObscure: true,
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        hintText: AppStrings.confirmPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.confirmPasswordRequired;
                        } else if (value.trim() !=
                            passwordController.text.trim()) {
                          return AppStrings.passwordsNotMatching;
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: context.screenWidth,
                      child: authVM.isLoading
                          ? AppLoader()
                          : AppButton(
                              onPressed: _handleSignUp,
                              buttonText: AppStrings.signUp,
                            ),
                    ),
                    SizedBox(height: 30),
                    RichText(
                      text: TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.black),
                        children: [
                          TextSpan(
                            text: AppStrings.login,
                            style: TextStyle(
                              color: AppColors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
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
    );
  }
}
