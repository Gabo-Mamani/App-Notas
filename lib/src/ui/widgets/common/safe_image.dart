import 'dart:io';
import 'package:flutter/material.dart';

class SafeImage extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final double radius;

  const SafeImage({
    super.key,
    required this.path,
    this.width = double.infinity,
    this.height = 100,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith("http");

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: isNetwork
            ? Image.network(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Center(child: Icon(Icons.broken_image, size: 40)),
              )
            : File(path).existsSync()
                ? Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Center(child: Icon(Icons.broken_image, size: 40)),
                  )
                : Center(child: Icon(Icons.broken_image, size: 40)),
      ),
    );
  }
}
