import 'package:flutter/material.dart';

class ImageUploadField extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialValue;

  const ImageUploadField({
    Key? key,
    required this.onImageSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  _ImageUploadFieldState createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialValue;
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picking and uploading
    // For now, we'll just simulate with a placeholder URL
    const placeholderUrl = 'https://via.placeholder.com/150';
    setState(() {
      _imageUrl = placeholderUrl;
    });
    widget.onImageSelected(placeholderUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_imageUrl != null)
          Container(
            width: 150,
            height: 150,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 48),
                  );
                },
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload),
          label: Text(_imageUrl == null ? 'Upload Image' : 'Change Image'),
        ),
      ],
    );
  }
} 