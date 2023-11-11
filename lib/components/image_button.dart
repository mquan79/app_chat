import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ImagePickerButton extends StatefulWidget {
  final void Function(String? imageUrl) onImageSelected;

  const ImagePickerButton({required this.onImageSelected, Key? key})
      : super(key: key);

  @override
  _ImagePickerButtonState createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      await storageReference.putFile(imageFile);

      String downloadURL = await storageReference.getDownloadURL();

      widget.onImageSelected(downloadURL);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: _pickImage,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
        child: const Icon(Icons.photo),
      ),
    );
  }
}
