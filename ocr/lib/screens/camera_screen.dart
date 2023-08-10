import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? message = '';
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  dynamic res, thresh, im_bw, matrix;
  Future _getImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  _scanImage() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://10.0.2.2:4000/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    log(message.toString());

    setState(() {});

    //await convertToPdf(message); // Convert the extracted text to PDF
  }

  // Function to create PDF and insert the extracted text
  /*Future<void> convertToPdf(String? extractedText) async {
    final pdf = pdfWidgets.Document();
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Text(extractedText ?? ''),
          );
        },
      ),
    );

    final output = await File('output.pdf').create();
    await output.writeAsBytes(await pdf.save());
  }*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              selectedImage == null
                  ? Text("Please pick a image to scan")
                  : Image.file(selectedImage!, fit: BoxFit.contain),
              TextButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
                onPressed: _scanImage,
                icon: Icon(Icons.scanner_outlined, color: Colors.white),
                label: Text(
                  "Scan",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                'Character in Image',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                '$message',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'getImage',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}// ngrok http 4000