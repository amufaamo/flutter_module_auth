// lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ⬅️ Web判定(kIsWeb)のために追加
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String emailLinkUrl;

  const LoginScreen({
    super.key,
    required this.emailLinkUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isEmailSent = false;

  // --- メールリンクでのログイン（送信） ---
  Future<void> _sendLoginLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    try {
      setState(() {
        _errorMessage = '';
        _isLoading = true;
      });

      // ActionCodeSettingsの設定
      // Webのみの運用の場合は、Android/iOSの設定を外すことでFDL(Firebase Dynamic Links)のエラーを回避できる場合があります。
      var acs = ActionCodeSettings(
        // URL: 認証完了後に開くURL。HostingのURLに合わせます。
        url: widget.emailLinkUrl,
        handleCodeInApp: true,
        // Webのみの場合は以下をコメントアウトまたは削除
        // iOSBundleId: 'com.example.testAuthApp',
        // androidPackageName: 'com.example.test_auth_app',
        // androidInstallApp: true,
        // androidMinimumVersion: '12',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );

      // メールアドレスをローカルに保存（リンク踏んだ時に使う）
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isEmailSent = true;
      });
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
        // final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
        // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        throw UnimplementedError('Google Sign In temporarily disabled');

        // if (googleUser == null) {
        //   // キャンセルされた場合
        //   setState(() => _isLoading = false);
        //   return;
        // }

        // // 認証情報を取得
        // final GoogleSignInAuthentication googleAuth =
        //     await googleUser.authentication;

        // // Firebase用クレデンシャル作成
        // final OAuthCredential credential = GoogleAuthProvider.credential(
        //   accessToken: null,
        //   idToken: googleAuth.idToken,
        // );

        // // Firebaseにサインイン
        // await _auth.signInWithCredential(credential);
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
    // 🎨 Use Theme Primary Color
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation:
                  0, // Flat modern look? Or keep default. Let's keep default but maybe softer.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0), // More breathing room
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 3. 新規登録への導線 (Title Update)
                    Text(
                      'Get Started',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade300,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    if (_isEmailSent) ...[
                      Icon(Icons.mark_email_read,
                          size: 64, color: primaryColor),
                      const SizedBox(height: 16),
                      const Text(
                        'Login link sent!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your email (${_emailController.text}) and click the link to sign in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEmailSent = false;
                          });
                        },
                        child: const Text('Back to Login',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ] else ...[
                      // --- Email Form ---
                      // 4. 入力フィールドのインタラクション (Focus & Validation)
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _emailController,
                        builder: (context, value, child) {
                          final isEmailValid = value.text.contains('@') &&
                              value.text.contains('.');
                          return TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade400),
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white70),
                              suffixIcon: isEmailValid
                                  ? Icon(Icons.check_circle,
                                      color: primaryColor)
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: primaryColor, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2C2C2C),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                          );
                        },
                      ),

                      // 2. 「マジックリンク」であることの補足
                      const SizedBox(height: 8),
                      Text(
                        'No password required. We will send you a login link.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.left,
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

                      // --- Send Link Button ---
                      // 1. ボタンの階層構造（ヒエラルキー）の明確化
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _sendLoginLink,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Send Login Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],

                    // --- Google Login ---
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text("OR",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: Image.network(
                        'https://fonts.gstatic.com/s/i/productlogos/googleg/v6/24px.svg',
                        height: 24,
                        width: 24,
                        color: Colors.white, // Tint icon white
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.login,
                                color: Colors.white), // Fallback
                      ),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.white,
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
