import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool disabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;

  const AppInput({
    Key? key,
    this.label,
    this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.disabled = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.autofocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          enabled: !disabled,
          readOnly: readOnly,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          style: TextStyle(
            color: disabled
                ? colorScheme.onSurface.withOpacity(0.5)
                : colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            contentPadding: contentPadding ?? const EdgeInsets.all(16),
            hintText: placeholder,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 16,
            ),
            filled: true,
            fillColor: disabled
                ? colorScheme.surfaceVariant.withOpacity(0.5)
                : colorScheme.surfaceVariant.withOpacity(0.3),
            errorText: errorText,
            helperText: helperText,
            helperStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            errorStyle: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onSuffixIconTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 