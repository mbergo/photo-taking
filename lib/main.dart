import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const PriceGO());
}

class PriceGO extends StatelessWidget {
  const PriceGO({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriceGO',
      theme: ThemeData.light().copyWith(
        textTheme: const TextTheme(),
      ),
      home: MyHomePage(
        title: 'PriceGO',
        camera: cameras.first,
        key: const Key('homePage'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(
      {required Key key, required this.title, required this.camera})
      : super(key: key);

  final String title;
  final CameraDescription camera;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController _controller =
      CameraController(cameras.first, ResolutionPreset.medium);
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _imageFile = File('pic.png');
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(_controller),
          ),
          // ignore: unnecessary_null_comparison
          // _imageFile == null ? Container() : Image.file(_imageFile),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final filePath = path.join(
                (await getTemporaryDirectory()).path,
                '${DateTime.now()}.png',
              );
              await _controller.takePicture();
              setState(() {
                _imageFile = File(filePath);
              });
              // send image to API
              final response = await http.post(
                'https://api.mbergo.guru' as Uri,
                body: _imageFile,
              );
              print(response.statusCode);
            },
          ),
        ],
      ),
    );
  }
}

class TakePicture extends StatelessWidget {
  const TakePicture({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text('Take Picture');
  }
}
