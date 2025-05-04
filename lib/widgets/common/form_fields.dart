import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberFormField extends StatelessWidget {
  final String labelText;
  final String? helperText;
  final int? initialValue;
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int?> onChanged;
  final bool required;

  const NumberFormField({
    Key? key,
    required this.labelText,
    this.helperText,
    this.initialValue,
    this.minValue,
    this.maxValue,
    required this.onChanged,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      initialValue: initialValue?.toString(),
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        final number = int.tryParse(value ?? '');
        if (number == null) {
          return 'Please enter a valid number';
        }
        if (minValue != null && number < minValue!) {
          return 'Value must be at least $minValue';
        }
        if (maxValue != null && number > maxValue!) {
          return 'Value must be at most $maxValue';
        }
        return null;
      },
      onChanged: (value) {
        final number = int.tryParse(value);
        onChanged(number);
      },
    );
  }
}

class DurationFormField extends StatelessWidget {
  final String labelText;
  final String? helperText;
  final Duration? initialValue;
  final ValueChanged<Duration?> onChanged;
  final bool required;

  const DurationFormField({
    Key? key,
    required this.labelText,
    this.helperText,
    this.initialValue,
    required this.onChanged,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialMinutes = initialValue?.inMinutes.toString();

    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText,
        border: const OutlineInputBorder(),
        suffixText: 'minutes',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      initialValue: initialMinutes,
      validator: (value) {
        if (required && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        final number = int.tryParse(value ?? '');
        if (number == null) {
          return 'Please enter a valid number';
        }
        if (number < 0) {
          return 'Duration cannot be negative';
        }
        return null;
      },
      onChanged: (value) {
        final minutes = int.tryParse(value);
        if (minutes != null) {
          onChanged(Duration(minutes: minutes));
        } else {
          onChanged(null);
        }
      },
    );
  }
}

class TagsFormField extends StatefulWidget {
  final List<String> initialTags;
  final ValueChanged<List<String>> onChanged;
  final String? helperText;

  const TagsFormField({
    Key? key,
    required this.initialTags,
    required this.onChanged,
    this.helperText,
  }) : super(key: key);

  @override
  _TagsFormFieldState createState() => _TagsFormFieldState();
}

class _TagsFormFieldState extends State<TagsFormField> {
  late List<String> _tags;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        widget.onChanged(_tags);
      });
      _controller.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      widget.onChanged(_tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Add Tags',
            helperText: widget.helperText,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_controller.text),
            ),
          ),
          onSubmitted: _addTag,
        ),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 