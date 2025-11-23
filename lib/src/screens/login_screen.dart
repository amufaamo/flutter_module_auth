// lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ⬅️ Web判定(kIsWeb)のために追加
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  // --- メールアドレスでのログイン ---
  Future<void> _login() async {
    try {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? "An error occurred";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  // --- 🆕 Googleログイン（Web対応・修正版） ---
  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      if (kIsWeb) {
        // 🌐【Webの場合】
        // ポップアップブロックやdeprecatedエラーを回避するため、
        // google_sign_in パッケージではなく、Firebase標準のポップアップを使います。
        GoogleAuthProvider authProvider = GoogleAuthProvider();

        // 必要に応じてログインのヒントなどを設定できます
        authProvider.setCustomParameters({'login_hint': 'user@example.com'});

        await _auth.signInWithPopup(authProvider);
      } else {
        // 📱【スマホアプリの場合】
        // Android/iOSは従来通り GoogleSignIn パッケージを使います。
        // クライアントIDは google-services.json / GoogleService-Info.plist から
        // 自動的に読み込まれるため、ここに書かなくても大丈夫です。
        final GoogleSignIn googleSignIn = GoogleSignIn();

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // キャンセルされた場合
          setState(() => _isLoading = false);
          return;
        }

        // 認証情報を取得
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Firebase用クレデンシャル作成
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: null,
          idToken: googleAuth.idToken,
        );

        // Firebaseにサインイン
        await _auth.signInWithCredential(credential);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? "Google Sign-In failed";
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Log in',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // --- Email Form ---
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          enabled: !_isLoading,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Error Message ---
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // --- Login Button ---
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Log In'),
                          ),

                    // --- Google Login ---
                    const SizedBox(height: 24),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text("OR", style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    // --- Sign Up Link ---
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      ),
                      child: const Text('Create New Account'),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
