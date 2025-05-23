import 'package:clica/utilities/assets_manager.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DisplayUserImage extends StatelessWidget {
  const DisplayUserImage({super.key, required this.finalFileImage, required this.radius, required this.onPressed,});
  final File? finalFileImage;
  final double radius;
  final VoidCallback onPressed;


  @override
  Widget build(BuildContext context) {
    return finalFileImage == null
                  ? Stack(
                      children: [
                         CircleAvatar(
                          radius: radius,
                          backgroundImage: const AssetImage(AssetsManager.userImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap:onPressed,
                            child:  CircleAvatar(
                              radius: 15,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        CircleAvatar(
                          radius: radius,
                          backgroundImage: FileImage(finalFileImage!),
                        ),
                         Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap:onPressed,
                            child:const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
  }
}