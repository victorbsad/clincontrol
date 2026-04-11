import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfThemeProvider {
  const PdfThemeProvider._();

  static Future<pw.ThemeData>? _cachedThemeFuture;

  static Future<pw.ThemeData> loadTheme() {
    _cachedThemeFuture ??= _buildTheme();
    return _cachedThemeFuture!;
  }

  static Future<pw.ThemeData> _buildTheme() async {
    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();
    final italic = await PdfGoogleFonts.notoSansItalic();
    final boldItalic = await PdfGoogleFonts.notoSansBoldItalic();

    return pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      italic: italic,
      boldItalic: boldItalic,
    );
  }
}
