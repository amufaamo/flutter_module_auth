import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  // --- ✏️ ここを編集してアプリのデザインを変えよう！ ---

  // 1. 基本の色 (seedColor)
  // ここを変えるだけで、アプリ全体のカラーテーマが自動で生成されます。
  // 例: Colors.pink, Colors.orange, Color(0xFF008080) など
  static const Color color = Colors.black;

  // 2. フォントの種類 (fontFamily)
  // アプリ全体の文字の見た目が変わります。
  // Google Fontsにあるフォント名を文字列で指定してください。
  // 例: 'Noto Sans JP', 'Roboto', 'M PLUS Rounded 1c'
  static const String fontFamily = 'Noto Sans JP';

  // 3. 基本のフォントサイズ (fontSize)
  static const double titleFontSize = 20.0; // AppBarのタイトルなど
  static const double bodyFontSize = 14.0;  // 本文のテキスト
  static const double buttonFontSize = 16.0; // ボタンのテキスト

  // 4. 角の丸み (borderRadius)
  // ボタンやカード、入力欄の角の丸みが変わります。
  static const double cornerRadius = 12.0;

  // 5. ボタンの縦の余白 (padding)
  static const double buttonVerticalPadding = 16.0;


  // --- ⚙️ ここから下はテーマの内部設定（上級者向け） ---
  // (基本的には編集不要です)

  static ThemeData _buildTheme(Brightness brightness) {
    // 1. カラーテーマを生成
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color, // 編集エリアの `color` を使用
      brightness: brightness,
    );

    // 2. フォントテーマを生成
    final baseTextTheme = GoogleFonts.getTextTheme(
      fontFamily, // 編集エリアの `fontFamily` を使用
      ThemeData(brightness: brightness).textTheme.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
    );

    // 3. 各パーツのスタイルを設定
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: baseTextTheme.copyWith(
        // 編集エリアのフォントサイズを適用
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: titleFontSize),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: bodyFontSize),
        labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: buttonFontSize),
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontSize: titleFontSize, // 編集エリアのサイズを適用
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: buttonVerticalPadding), // 編集エリアの余白を適用
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius), // 編集エリアの角丸を適用
          ),
          textStyle: baseTextTheme.labelLarge?.copyWith(
            fontSize: buttonFontSize, // 編集エリアのサイズを適用
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius), // 編集エリアの角丸を適用
        ),
        color: colorScheme.surfaceContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius), // 編集エリアの角丸を適用
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cornerRadius), // 編集エリアの角丸を適用
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
      ),
    );
  }

  // ライトモード用のテーマ
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ダークモード用のテーマ
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
}
