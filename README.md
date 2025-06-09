# Flutter Auth UI

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Firebase Authenticationのための、美しくカスタマイズ可能なUIコンポーネントを提供するFlutterパッケージです。

このパッケージを使えば、ログイン、新規登録、パスワードリセットといった認証画面を、あなたのアプリに素早く組み込むことができます。

## ✨ 特徴

- ログイン画面 (`LoginScreen`)
- 新規登録画面 (`SignUpScreen`)
- パスワードリセット画面 (`ForgotPasswordScreen`)
- `AppTheme` による簡単なテーマのカスタマイズ

## 🚀 使い方

### 1. インストール
`pubspec.yaml` の `dependencies` に以下を追加してください。

```yaml
dependencies:
  flutter_auth_ui:
    git:
      url: [https://github.com/YOUR_USERNAME/flutter_auth_ui.git](https://github.com/YOUR_USERNAME/flutter_auth_ui.git)
      ref: main
````

（`YOUR_USERNAME` の部分は、あなたのGitHubユーザー名に置き換えてください）

### 2\. 基本的な使用例

`FirebaseAuth.instance.authStateChanges()` をリッスンし、認証状態に応じて画面を切り替えるのが基本的な使い方です。

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_ui/flutter_auth_ui.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ログインしている場合
        if (snapshot.hasData) {
          return const HomeScreen(); // あなたのアプリのホーム画面
        }
        // ログインしていない場合
        return const LoginScreen(); // このパッケージが提供するログイン画面
      },
    );
  }
}
```

## ライセンス

このプロジェクトはMITライセンスです。

```

#### 2. `LICENSE` ファイルの作成
誰でも安心して使えるように、ライセンス（使用許諾）を明記します。`flutter_auth_ui` フォルダの直下に `LICENSE` という名前のファイル（拡張子なし）を作成し、以下の内容を貼り付けます。これは一般的な `MIT License` というもので、とても自由度の高いライセンスです。

```

MIT License

Copyright (c) 2025 YOUR\_NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

````
（`2025 YOUR_NAME` の部分は、現在の年とあなたのお名前に書き換えてくださいね）

#### 3. `CHANGELOG.md` の更新
`flutter_auth_ui` フォルダの直下にある `CHANGELOG.md` を開き、最初のバージョン情報を記録します。

```markdown
## 1.0.0

- Initial version of the package.
- Provides LoginScreen, SignUpScreen, and ForgotPasswordScreen.
````
