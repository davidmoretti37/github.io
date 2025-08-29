import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum ButtonSize {
  small,
  medium,
  large,
  icon,
}

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final Widget? icon;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.icon,
  }) : assert(text != null || child != null, 'Either text or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get button styling based on variant
    final buttonStyle = _getButtonStyle(theme);
    final textStyle = _getTextStyle(theme);
    final padding = _getPadding();
    final height = _getHeight();

    Widget buttonChild;
    if (child != null) {
      buttonChild = child!;
    } else if (icon != null && text != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text!, style: textStyle),
        ],
      );
    } else if (icon != null) {
      buttonChild = icon!;
    } else {
      buttonChild = Text(text!, style: textStyle);
    }

    if (variant == ButtonVariant.link) {
      return InkWell(
        onTap: disabled ? null : onPressed,
        child: Container(
          height: height,
          padding: padding,
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: buttonStyle,
        child: Padding(
          padding: padding,
          child: buttonChild,
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.primary.withOpacity(0.9);
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.primary;
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        );

      case ButtonVariant.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.error.withOpacity(0.9);
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.error;
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        );

      case ButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.surfaceVariant;
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.surface;
            }
            return colorScheme.surface;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.onSurfaceVariant;
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onSurface;
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        );

      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.secondary.withOpacity(0.8);
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return colorScheme.secondary;
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        );

      case ButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.surfaceVariant;
            }
            if (states.contains(MaterialState.disabled)) {
              return Colors.transparent;
            }
            return Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return colorScheme.onSurfaceVariant;
            }
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.38);
            }
            return colorScheme.onSurface;
          }),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        );

      case ButtonVariant.link:
        return ElevatedButton.styleFrom(); // Not used for link variant
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    if (variant == ButtonVariant.link) {
      return baseStyle.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: theme.colorScheme.primary,
      );
    }

    return baseStyle;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 0);
      case ButtonSize.icon:
        return EdgeInsets.zero;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 40;
      case ButtonSize.large:
        return 44;
      case ButtonSize.icon:
        return 40;
    }
  }
}
