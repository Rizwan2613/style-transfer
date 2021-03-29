import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Interpreter _interpreter1;
  Interpreter _interpreter2;
  img.Image aimage;
  bool isLoading = false;

//------------------------------------------------------------------------//
//------------------------------------------------------------------------//
  List generate4dList(Float32List fList) {
    //this function will return 4D Array made by a flatten array

    var list = List.generate(
        1,
        (i) => List.generate(256,
            (j) => List.generate(256, (k) => List.generate(3, (l) => 0.0))));
    int y = 0;
    for (int j = 0; j < 256; j++) {
      for (int k = 0; k < 256; k++) {
        list[0][j][k][0] = fList[0 + 3 * y];
        list[0][j][k][1] = fList[1 + 3 * y];
        list[0][j][k][2] = fList[2 + 3 * y];
        y++;
      }
    }
    return list;
  }

  img.Image createImage(List list, int inputSize) {
    img.Image image = img.Image(inputSize, inputSize);
    img.fill(image, img.getColor(0, 0, 0));
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        double redValue = list[0][i][j][0];
        double greenValue = list[0][i][j][1];
        double blueValue = list[0][i][j][2];
        img.drawPixel(
            image,
            i,
            j,
            img.getColor((redValue * 255).round(), (greenValue * 255).round(),
                (blueValue * 255).round()));
      }
    }
    return image;
  }

  Uint8List generate1dList(List list, int inputSize) {
    Uint8List retList = new Uint8List(inputSize * inputSize * 3);
    retList.fillRange(0, inputSize * inputSize * 3 - 1, 0);
    for (int i = 0; i < inputSize; i++) {
      for (int j = 0; j < inputSize; j++) {
        for (int k = 0; k < 3; k++) {
          double item = list[0][i][j][k];
          retList[i * inputSize + j * 3 + k] = (item * 255.0).round();
        }
      }
    }
    return retList;
  }

//----------------------------------------------------------------//
//----------------------------------------------------------------//
  Float32List imageToByteListFloat32(img.Image image, int inputSize) {
    //this function is returning a Float list of RGB values of every
    //pixel ranging [0,1]

    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(i, j);
        buffer[pixelIndex++] = img.getRed(pixel).toDouble();
        buffer[pixelIndex++] = img.getGreen(pixel).toDouble();
        buffer[pixelIndex++] = img.getBlue(pixel).toDouble();
      }
    }
    var normalized = Float32List.view(convertedBytes.buffer);
    for (int x = 0; x < buffer.length; x++) {
      normalized[x] = (buffer[x] - buffer.reduce(min)) /
          (buffer.reduce(max) - buffer.reduce(min));
    }
    print(normalized);
    return normalized;
  }

  //-----------------------------------------------------------//
  //-----------------------------------------------------------//

  void seState() async {
    //setState method

    isLoading = true;
    final ByteData data = await rootBundle.load("assets/style23 (1).jpg");
    img.Image baseSizeImage = img.decodeImage(data.buffer.asUint8List());
    img.Image resizeImage =
        img.copyResize(baseSizeImage, height: 256, width: 256);

    Float32List flist = imageToByteListFloat32(resizeImage, 256);
    List list = generate4dList(flist);
    print(list);

    final ByteData content = await rootBundle.load("assets/huzaifa.jpg");
    img.Image baseSize = img.decodeImage(content.buffer.asUint8List());
    img.Image resizeImageContent =
        img.copyResize(baseSize, height: 384, width: 384);

    Float32List flistContent = imageToByteListFloat32(resizeImageContent, 384);
    List listContent = generate4dList(flistContent);
    print(listContent);

    _interpreter1 = await Interpreter.fromAsset("predict.tflite");
    _interpreter2 = await Interpreter.fromAsset("transf.tflite");
    _interpreter1.allocateTensors();

    var output = List.generate(
        1,
        (i) => List.generate(
            1, (j) => List.generate(1, (k) => List.generate(100, (k) => 0.0))));
    _interpreter1.run(list, output);
    print(output.shape);
    _interpreter1.close();

    var imageOutput = List.generate(
        1,
        (i) => List.generate(384,
            (j) => List.generate(384, (k) => List.generate(3, (k) => 0.0))));

    Map<int, Object> stylizedImage = {0: imageOutput};
    _interpreter2.allocateTensors();

    var inputs = [listContent, output];
    _interpreter2.runForMultipleInputs(inputs, stylizedImage);
    print(imageOutput);
    _interpreter2.close();
    Uint8List lis = generate1dList(imageOutput, 384);
    img.Image image = createImage(imageOutput, 384);
    setState(() {
      print(lis.length);
      aimage = image;
      //File('assets/image.jpg').writeAsBytesSync(img.encodeJpg(image));
    });

    //aimage = img.decodeImage(lis);
    isLoading = false;
  }

  //---------------------------------------------------------------------//
  //---------------------------------------------------------------------//
  Uint8List loadImage() {
    if (aimage == null) {
      img.Image image = img.Image(480, 480);
      img.fill(image, img.getColor(0, 0, 255));
      img.Image resizeImageContent =
          img.copyResize(image, height: 384, width: 384);

      return img.encodeJpg(resizeImageContent);
    } else {
      return img.encodeJpg(aimage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      theme: ThemeData(primaryColor: Colors.orangeAccent),
      title: "Style Transfer App",
      home: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          "assets/huzaifa.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                          child: Image.asset(
                        "assets/style23 (1).jpg",
                        fit: BoxFit.cover,
                      ))
                    ],
                  ),
                  Expanded(child: Image.memory(loadImage())),
                  Expanded(
                    child: IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () {
                          seState();
                        }),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
