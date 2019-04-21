import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageCapture extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  _buildCamera() {
    return Container(
      child: Column(
        children: <Widget>[
          new Center(
            child: _image == null
                ? new Text("No image selected")
                : new Image.file(_image),
          ),
          RaisedButton(
            onPressed: getImage,
            child: Icon(Icons.camera),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image Picker'),
        ),
        body: Center(
          child: _image == null ? new Text('No image selected') : new Image
              .file(_image),
        ),
        floatingActionButton: FloatingActionButton(onPressed: getImage,
            tooltip: 'Pick Image',
            child: Icon(Icons.camera)),
      ),
    );
  }
}