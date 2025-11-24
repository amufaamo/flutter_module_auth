import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailLinkHandler {
  static Future<void> handleLink(String link) async {
    final auth = FirebaseAuth.instance;
    if (auth.isSignInWithEmailLink(link)) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      // final email = 'test@example.com'; // Temporary hardcode

      if (email != null) {
        await auth.signInWithEmailLink(
          email: email,
          emailLink: link,
        );
      } else {
        // メールアドレスが保存されていない場合（別の端末で開いた場合など）
        // ユーザーにメールアドレスの入力を求める必要がありますが、
        // ここでは簡易的にエラーとするか、何もしないか。
        // 実運用ではUIを表示して入力を促すのがベストですが、
        // 今回は「同じ端末で開く」前提で進めます。
        print('Email not found in SharedPreferences');
        throw FirebaseAuthException(
          code: 'email-not-found',
          message:
              'Email address not found. Please sign in again on this device.',
        );
      }
    }
  }
}
