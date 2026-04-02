import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Handwritten on paper" theme — blue ink on lined paper.
class PaperTheme {
  PaperTheme._();

  // ── Colours ──────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF1A3A5C); // dark blue ink
  static const Color inkLight = Color(0xFF4A7DAD); // lighter accent
  static const Color paper = Color(0xFFF5F0E8); // warm cream paper
  static const Color paperDark = Color(0xFFEDE7DA); // slightly darker
  static const Color ruled = Color(0xFFCDD8E4); // blue ruled lines
  static const Color ruledLight = Color(0xFFDDE6EF);
  static const Color margin = Color(0xFFE8A0A0); // red margin line
  static const Color checked = Color(0xFF8BA4B8); // muted blue for done
  static const Color error = Color(0xFFC0392B);

  // ── Text theme ───────────────────────────────────────────────────────
  static TextTheme get _textTheme {
    final base = GoogleFonts.patrickHandTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(color: ink),
      displayMedium: base.displayMedium?.copyWith(color: ink),
      displaySmall: base.displaySmall?.copyWith(color: ink),
      headlineLarge: base.headlineLarge?.copyWith(color: ink),
      headlineMedium: base.headlineMedium?.copyWith(color: ink),
      headlineSmall: base.headlineSmall?.copyWith(color: ink),
      titleLarge: base.titleLarge?.copyWith(color: ink, fontSize: 28),
      titleMedium: base.titleMedium?.copyWith(color: ink, fontSize: 24),
      titleSmall: base.titleSmall?.copyWith(color: ink, fontSize: 20),
      bodyLarge: base.bodyLarge?.copyWith(color: ink, fontSize: 22),
      bodyMedium: base.bodyMedium?.copyWith(color: ink, fontSize: 20),
      bodySmall: base.bodySmall?.copyWith(color: ink, fontSize: 18),
      labelLarge: base.labelLarge?.copyWith(color: ink, fontSize: 20),
      labelMedium: base.labelMedium?.copyWith(color: ink, fontSize: 18),
      labelSmall: base.labelSmall?.copyWith(color: ink, fontSize: 16),
    );
  }

  // ── ThemeData ────────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: ink,
        onPrimary: paper,
        primaryContainer: ruledLight,
        onPrimaryContainer: ink,
        secondary: inkLight,
        onSecondary: paper,
        secondaryContainer: ruled,
        onSecondaryContainer: ink,
        surface: paper,
        onSurface: ink,
        error: error,
        onError: paper,
        outline: checked,
        outlineVariant: ruled,
      ),
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: GoogleFonts.patrickHand(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        iconTheme: const IconThemeData(color: ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: paperDark,
        indicatorColor: ruled,
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: Color.fromARGB(179, 0x1A, 0x3A, 0x5C)),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.patrickHand(fontSize: 14, color: ink),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ink,
        unselectedLabelColor: checked,
        indicatorColor: ink,
        labelStyle: GoogleFonts.patrickHand(fontSize: 18),
        unselectedLabelStyle: GoogleFonts.patrickHand(fontSize: 18),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ink,
        foregroundColor: paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: ruled, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ruledLight,
        labelStyle: GoogleFonts.patrickHand(fontSize: 14, color: ink),
        side: BorderSide(color: ruled),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return ink;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(paper),
        side: BorderSide(color: ink, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        labelStyle: GoogleFonts.patrickHand(color: checked, fontSize: 18),
        hintStyle: GoogleFonts.patrickHand(color: checked, fontSize: 16),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: ruled),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ruled),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: ink, width: 2),
        ),
        isDense: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        titleTextStyle: GoogleFonts.patrickHand(
          fontSize: 24,
          color: ink,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.patrickHand(fontSize: 18, color: ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: paper,
          textStyle: GoogleFonts.patrickHand(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: GoogleFonts.patrickHand(fontSize: 18),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          textStyle: GoogleFonts.patrickHand(fontSize: 18),
          side: BorderSide(color: ruled),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: ruled, thickness: 1),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.patrickHand(fontSize: 22, color: ink),
        subtitleTextStyle:
            GoogleFonts.patrickHand(fontSize: 18, color: checked),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: paper,
        textStyle: GoogleFonts.patrickHand(fontSize: 18, color: ink),
      ),
      iconTheme: const IconThemeData(color: ink),
    );
  }
}

/// A widget that paints horizontal ruled lines (like notebook paper).
class RuledPaperBackground extends StatelessWidget {
  final Widget child;
  final double lineSpacing;
  final bool showMargin;

  const RuledPaperBackground({
    super.key,
    required this.child,
    this.lineSpacing = 32,
    this.showMargin = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RuledPaperPainter(
        lineSpacing: lineSpacing,
        lineColor: PaperTheme.ruled,
        marginColor: PaperTheme.margin,
        showMargin: showMargin,
      ),
      child: child,
    );
  }
}

class _RuledPaperPainter extends CustomPainter {
  final double lineSpacing;
  final Color lineColor;
  final Color marginColor;
  final bool showMargin;

  _RuledPaperPainter({
    required this.lineSpacing,
    required this.lineColor,
    required this.marginColor,
    required this.showMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5;

    for (double y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    if (showMargin) {
      final marginPaint = Paint()
        ..color = marginColor
        ..strokeWidth = 1.0;
      canvas.drawLine(
        const Offset(48, 0),
        Offset(48, size.height),
        marginPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RuledPaperPainter old) =>
      lineSpacing != old.lineSpacing ||
      lineColor != old.lineColor ||
      showMargin != old.showMargin;
}
