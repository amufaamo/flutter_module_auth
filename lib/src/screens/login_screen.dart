// lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ⬅️ Web判定(kIsWeb)のために追加
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
        url: 'https://authentication-61d1a.web.app/finishSignUp',
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

                    if (_isEmailSent) ...[
                      const Icon(Icons.mark_email_read,
                          size: 64, color: Colors.green),
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
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isEmailSent = false;
                          });
                        },
                        child: const Text('Back to Login'),
                      ),
                    ] else ...[
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
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _sendLoginLink,
                              child: const Text('Send Login Link'),
                            ),
                    ],

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
