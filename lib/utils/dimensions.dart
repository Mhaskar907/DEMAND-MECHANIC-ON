// lib/utils/dimensions.dart
import 'package:flutter/material.dart';

class Dimensions {
  final BuildContext context;
  late double screenHeight;
  late double screenWidth;

  Dimensions(this.context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }

  // page view
  double get pageView => screenHeight / 2.64;
  double get pageViewContainer => screenHeight / 3.84;
  double get pageViewTextContainer => screenHeight / 7.03;

  // dynamic height padding and margin
  double get height10 => screenHeight / 84.4;
  double get height15 => screenHeight / 56.27;
  double get height20 => screenHeight / 42.2;
  double get height30 => screenHeight / 28.13;
  double get height45 => screenHeight / 18.76;

  // dynamic width padding and margin
  double get width10 => screenWidth / 84.4;
  double get width15 => screenWidth / 56.27;
  double get width20 => screenWidth / 42.2;
  double get width30 => screenWidth / 28.13;

  // font sizes
  double get font16 => screenHeight / 52.75;
  double get font20 => screenHeight / 42.2;
  double get font26 => screenHeight / 32.46;

  // radius
  double get radius15 => screenHeight / 56.27;
  double get radius20 => screenHeight / 42.2;
  double get radius30 => screenHeight / 28.13;

  // icon sizes
  double get iconSize24 => screenHeight / 35.17;
  double get iconSize16 => screenHeight / 52.75;

  // list view
  double get listViewImgSize => screenWidth / 3.25;
  double get listViewTextContSize => screenWidth / 3.9;

  // popular food
  double get popularFoodImgSize => screenHeight / 2.41;

  // bottom height
  double get bottomHeightBar => screenHeight / 7.03;

  // splash screen
  double get splashImg => screenHeight / 3.38;
  
  // Additional common dimensions
  double get height5 => screenHeight / 168.8;
  double get height8 => screenHeight / 105.5;
  double get height12 => screenHeight / 70.3;
  double get height16 => screenHeight / 52.75;
  double get height24 => screenHeight / 35.17;
  double get height32 => screenHeight / 26.375;
  double get height40 => screenHeight / 21.1;
  double get height48 => screenHeight / 17.58;
  double get height56 => screenHeight / 15.07;
  double get height60 => screenHeight / 14.07;
  double get height80 => screenHeight / 10.55;
  double get height100 => screenHeight / 8.44;
  double get height120 => screenHeight / 7.03;
  double get height140 => screenHeight / 6.03;
  
  double get width5 => screenWidth / 82.8;
  double get width8 => screenWidth / 51.75;
  double get width12 => screenWidth / 34.5;
  double get width16 => screenWidth / 25.875;
  double get width24 => screenWidth / 17.25;
  double get width32 => screenWidth / 12.9375;
  double get width40 => screenWidth / 10.35;
  double get width48 => screenWidth / 8.625;
  double get width60 => screenWidth / 6.9;
  double get width80 => screenWidth / 5.175;
  double get width120 => screenWidth / 3.45;
  
  // radius helpers
  double get radius8 => screenHeight / 105.5;
  double get radius10 => screenHeight / 84.4;
  double get radius12 => screenHeight / 70.3;
  double get radius16 => screenHeight / 52.75;
  double get radius24 => screenHeight / 35.17;
  
  // font helpers
  double get font12 => screenHeight / 70.3;
  double get font14 => screenHeight / 60.3;
  double get font18 => screenHeight / 46.9;
  double get font22 => screenHeight / 38.4;
  double get font24 => screenHeight / 35.17;
  double get font28 => screenHeight / 30.14;
  double get font32 => screenHeight / 26.375;
}
