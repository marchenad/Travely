import 'package:flutter/material.dart';

class AppConstants {
  // Neobrutalism Styles
  static const Color primaryColor = Color(0xFFE6FF00); // Yellow/Lime
  static const Color secondaryColor = Colors.white;
  static const Color shadowColor = Colors.black;
  
  static const double borderWidth = 3.0;
  static const Offset shadowOffset = Offset(5, 5); // Actualizado a (5, 5)

  static final BoxBorder neoBorder = Border.all(
    color: shadowColor,
    width: borderWidth,
  );

  static final List<BoxShadow> neoShadow = [
    const BoxShadow(
      color: shadowColor,
      offset: shadowOffset,
      blurRadius: 0,
    ),
  ];

  static const TextStyle neoHeaderStyle = TextStyle(
    fontWeight: FontWeight.w900,
    fontSize: 20,
    color: Colors.black,
  );

  // Map Config
  static const String mapUserAgent = 'com.travely.app';
  static const String osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';
}
