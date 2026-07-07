import 'dart:ui';
import 'package:flutter/material.dart';

class AdminUi {
  static const Color bg = Color(0xFFF4F7F6);
  static const Color primaryGreen = Color(0xFF1F6D44);
  static const Color darkGreen = Color(0xFF163829);
  static const Color softGreen = Color(0xFFEAF6EF);
  static const Color borderColor = Color(0xFFDDE9E1);
  static const Color textDark = Color(0xFF1F2A24);
  static const Color textSoft = Color(0xFF6E7C74);
  static const Color danger = Color(0xFFD05C5C);
  static const Color gold = Color(0xFFD9A441);
  static const Color blue = Color(0xFF4B78D1);
}

class AdminGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AdminGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.74),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AdminUi.borderColor.withOpacity(0.95)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final Color? color;
  final double minWidth;

  const AdminActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.color,
    this.minWidth = 170,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AdminUi.primaryGreen;

    return SizedBox(
      height: 46,
      child: primary
          ? FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                minimumSize: Size(minWidth, 46),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonColor,
                minimumSize: Size(minWidth, 46),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                side: BorderSide(color: buttonColor.withOpacity(0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(icon, size: 18),
              label: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
    );
  }
}

class AdminProductImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double radius;

  const AdminProductImage({
    super.key,
    required this.imageUrl,
    this.size = 58,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: AdminUi.softGreen,
        child: hasImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.fastfood_rounded,
          color: AdminUi.primaryGreen,
          size: 28,
        ),
      ),
    );
  }
}