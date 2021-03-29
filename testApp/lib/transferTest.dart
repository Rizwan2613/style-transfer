// import 'dart:async';
// import 'dart:collection';
// import 'dart:ffi';
// import 'dart:io' as io;
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:flutter/widgets.dart';
// import 'dart:ui' as ui;
// import 'package:image/image.dart' as img;
// //import 'package:flutter_native_image/flutter_native_image.dart';
// // import 'package:image_native_resizer/image_native_resizer.dart' as inr;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppstate createState() => _MyAppstate();
// }

// class _MyAppstate extends State<MyApp> {
//   Interpreter _interpreter1;
//   Interpreter _interpreter2;

//   List generateList(Float32List fList) {
//     var list = List.generate(
//         1,
//         (i) => List.generate(256,
//             (j) => List.generate(256, (k) => List.generate(3, (l) => 0.0))));
//     int y = 0;
//     for (int j = 0; j < 256; j++) {
//       for (int k = 0; k < 256; k++) {
//         list[0][j][k][0] = fList[0 + 3 * y];
//         list[0][j][k][1] = fList[1 + 3 * y];
//         list[0][j][k][2] = fList[2 + 3 * y];
//         y++;
//       }
//     }
//     return list;
//   }

//   Float32List imageToByteListFloat32(img.Image image, int inputSize) {
//     var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
//     var buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;
//     for (var i = 0; i < inputSize; i++) {
//       for (var j = 0; j < inputSize; j++) {
//         var pixel = image.getPixel(i, j);
//         buffer[pixelIndex++] = img.getRed(pixel).toDouble();
//         buffer[pixelIndex++] = img.getGreen(pixel).toDouble();
//         buffer[pixelIndex++] = img.getBlue(pixel).toDouble();
//       }
//     }
//     // print(buffer);
//     // print(buffer.shape);

//     final lower = buffer.reduce(min);
//     final upper = buffer.reduce(max);
//     // // //normalized = [];

//     var normalized = Float32List.view(convertedBytes.buffer);
//     for (int x = 0; x < buffer.length; x++) {
//       normalized[x] = (buffer[x] - lower) / (upper - lower);
//     }
//     // // buffer.forEach((element) => element < 0
//     // //     ? normalized.add(-(element / lower))
//     // //     : normalized.add(element / upper));
//     // //print(normalized.flatten());
//     // print(buffer.shape);
//     // print(normalized.shape);
//     // print(normalized.buffer.asFloat32List());
//     // print(normalized.buffer.asFloat32List().shape);
//     // return convertedBytes

//     return normalized.buffer.asFloat32List();
//   }

//   void seState() async {
// // 1. get [ImageProvider] instance
// //    [ExactAssetImage] extends [AssetBundleImageProvider] extends [ImageProvider]
//     //ExactAssetImage provider = ExactAssetImage('assets/style.jpg');

// // 2. get [ui.Image] by [ImageProvider]
// //     ImageStream stream = provider.resolve(ImageConfiguration.empty);
// //     Completer completer = Completer<ui.Image>();
// //     ImageStreamListener listener = ImageStreamListener((frame, sync) {
// //       ui.Image image = frame.image;
// //       completer.complete(image);
// //     });
// //     stream.addListener(listener);

// // // 3. get rgba array/list by [ui.Image]
// //     completer.complete((ui.Image image) {
// //       image
// //           .toByteData(format: ui.ImageByteFormat.rawRgba)
// //           .then((ByteData data) {
// //         rGBAList = data.buffer.asUint8List().toList();
// //       });
// //     });

// //     print(rGBAList);

//     // var list =
//     //     (await rootBundle.load("assets/style.jpg")).buffer.asFloat32List();

//     final ByteData data = await rootBundle.load("assets/style.jpg");
//     img.Image baseSizeImage = img.decodeImage(data.buffer.asUint8List());
//     img.Image resizeImage =
//         img.copyResize(baseSizeImage, height: 256, width: 256);
//     // print(encoder);

//     Float32List flist = imageToByteListFloat32(resizeImage, 256);
//     List list = generateList(flist);
//     print(list);

//     final ByteData content = await rootBundle.load("assets/huzaifa.jpg");
//     img.Image baseSize = img.decodeImage(content.buffer.asUint8List());
//     img.Image resizeImageContent =
//         img.copyResize(baseSize, height: 384, width: 384);
//     // print(encoder);

//     Float32List flistContent = imageToByteListFloat32(resizeImageContent, 384);
//     List listContent = generateList(flistContent);
//     print(listContent);
//     //print(list);

//     // Image image = Image.asset(
//     //   "assets/style.jpg",
//     //   width: 256,
//     //   height: 256,
//     // );
//     // print(image);

//     // final resizedPath = await inr.ImageNativeResizer.resize(
//     //   imagePath: "assets/style.jpg",
//     //   maxWidth: 256,
//     //   maxHeight: 256,
//     //   quality: 50,
//     // );
//     // print(resizedPath);
//     // io.File compressedFile = await FlutterNativeImage.compressImage(
//     //     "assets/style.jpg",
//     //     quality: 80,
//     //     targetWidth: 256,
//     //     targetHeight: 256);
//     // print(compressedFile);
//     // var input =

//     _interpreter1 = await Interpreter.fromAsset(
//         "magenta_arbitrary-image-stylization-v1-256_int8_prediction_1.tflite");
//     _interpreter2 = await Interpreter.fromAsset("transfer.tflite");
//     _interpreter1.allocateTensors();

//     // // // Image input = Image.asset("assets/style.jpg");

//     var output = List.generate(
//         1,
//         (i) => List.generate(
//             1, (j) => List.generate(1, (k) => List.generate(100, (k) => 0.0))));
//     _interpreter1.run(list, output);
//     print(output.shape);
//     _interpreter1.close();

//     var imageOutput = List.generate(
//         1,
//         (i) => List.generate(384,
//             (j) => List.generate(384, (k) => List.generate(3, (k) => 0.0))));

//     Map<int, Object> stylizedImage = {0: imageOutput};
//     _interpreter2.allocateTensors();

//     var inputs = [listContent, output];
//     _interpreter2.runForMultipleInputs(inputs, stylizedImage);
//     print(imageOutput);
//     _interpreter2.close();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primaryColor: Colors.blueGrey[900]),
//       darkTheme: ThemeData.dark(),
//       title: "Transfer App",
//       home: Scaffold(
//         appBar: AppBar(),
//         body: Center(
//             child: Container(
//           padding: EdgeInsets.all(10),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Image.asset(
//                       "assets/huzaifa.jpg",
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   Expanded(
//                       child: Image.asset(
//                     "assets/style.jpg",
//                     fit: BoxFit.cover,
//                   ))
//                 ],
//               ),
//               RaisedButton(
//                 onPressed: () {
//                   seState();
//                 },
//                 child: Text("click"),
//               )
//             ],
//           ),
//         )),
//       ),
//     );
//   }
// }
