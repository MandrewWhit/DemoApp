import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cattle Detector 3000',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cattle Detector 3000'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _path;
  String? _result;

  Future _pickImage() async {
    try {
      var image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = XFile(image.path);
      var visionImage = InputImage.fromFilePath(image.path);
      ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();
      var imageLabels = await imageLabeler.processImage(visionImage);
      setState(() {
        _path = imageTemp.path;
      });
      bool cowFound = false;
      setState(() => _result = "");
      for (ImageLabel imageLabel in imageLabels) {
        if (imageLabel.label.toLowerCase().contains("cow") ||
            imageLabel.label.toLowerCase().contains("cattle")) {
          cowFound = true;
          break;
        }
      }
      if (cowFound) {
        setState(() {
          _result = "Cow found!";
        });
      } else {
        setState(() {
          _result = "No cow found!";
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to pick image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _path == null
                ? const Text('No image selected.')
                : ExtendedImage.file(
                    File(_path ?? 'assets/camera21.png'),
                    fit: BoxFit.contain,
                    cacheHeight: 150,
                    cacheWidth: 200,
                  ),
            _result == null
                ? const Text("")
                : Padding(
                    padding: const EdgeInsets.all(16.0), child: Text(_result!)),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            tooltip: 'Pick Image',
            child: const Icon(Icons.add_a_photo),
          ),
        ],
      ),
    );
  }
}
