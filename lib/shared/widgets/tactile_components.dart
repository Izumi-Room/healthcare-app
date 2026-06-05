import 'package:flutter/material.dart';

/// A custom, premium 3D tactile button inspired by Duolingo.
/// Simulates a physical press by sliding down into its bottom border shadow on click.
class Tactile3DButton extends StatefulWidget {
  const Tactile3DButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = const Color(0xFF58CC02), // Vibrant green
    this.shadowColor = const Color(0xFF46A302), // Darker green shadow
    this.height = 54.0,
    this.width = double.infinity,
    this.borderRadius = 16.0,
    this.disabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double height;
  final double width;
  final double borderRadius;
  final bool disabled;

  @override
  State<Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<Tactile3DButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double depth = 4.0;
    final double topOffset = _isPressed ? depth : 0.0;
    final double bottomOffset = _isPressed ? 0.0 : depth;

    final effectiveBgColor = widget.disabled
        ? Colors.grey.shade300
        : widget.backgroundColor;
    final effectiveShadowColor = widget.disabled
        ? Colors.grey.shade400
        : widget.shadowColor;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: widget.width,
        height: widget.height + depth,
        child: Stack(
          children: [
            // Shadow Layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: depth,
              child: Container(
                decoration: BoxDecoration(
                  color: effectiveShadowColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
              ),
            ),
            // Button Body Layer
            AnimatedPositioned(
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeIn,
              top: topOffset,
              bottom: bottomOffset,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: effectiveBgColor,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1.5,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom TextField with premium, rounded, chunky borders inspired by Duolingo.
class TactileTextField extends StatefulWidget {
  const TactileTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  State<TactileTextField> createState() => _TactileTextFieldState();
}

class _TactileTextFieldState extends State<TactileTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const activeColor = Color(0xFF1CB0F6); // Duolingo sky blue for focus
    final idleColor = isDark ? Colors.white24 : Colors.grey.shade300;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelStyle: TextStyle(
          color: _isFocused ? activeColor : (isDark ? Colors.white54 : Colors.grey.shade600),
          fontWeight: FontWeight.bold,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF7F7F7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: idleColor,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: activeColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2.0,
          ),
        ),
        errorStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
