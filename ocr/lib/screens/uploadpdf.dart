import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart'; // For getting the file name from the path.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Upload to Firebase',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _pdfFile;
  final picker = ImagePicker();

  // Function to pick a PDF file from device storage.
  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  // Function to upload the PDF to Firebase Storage.
  Future<String?> _uploadPDFToFirebase() async {
    if (_pdfFile == null) {
      print("No PDF file selected.");
      return null; // Return null when there's no PDF file.
    }

    String fileName = basename(_pdfFile!.path);
    Reference storageReference =
        FirebaseStorage.instance.ref().child('pdfs/$fileName');
    UploadTask uploadTask = storageReference.putFile(_pdfFile!);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Upload to Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              onPressed: _pickPDF,
              icon: Icon(Icons.file_upload), // Add file upload icon
              tooltip: 'Select PDF',
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                String? downloadUrl = await _uploadPDFToFirebase();
                if (downloadUrl != null) {
                  print("PDF uploaded to Firebase. Download URL: $downloadUrl");
                } else {
                  print("No PDF file selected.");
                }
              },
              icon: Icon(Icons.cloud_upload), // Add cloud upload icon
              label: Text('Upload PDF to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
