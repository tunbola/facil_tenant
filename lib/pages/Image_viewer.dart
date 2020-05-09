import 'package:flutter/material.dart';
import 'package:facil_tenant/styles/colors.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  ImageViewer(this.imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, title: Text("Image viewer", style: TextStyle(color: shedAppBlue400),),),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.network(imageUrl),
      ),
    );
  }
}