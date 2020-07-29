import 'constants.dart';

//The dimmensions in pixels of the mobile device that is currently running the application
double appcheight = 360;
double appcwidth = 681;

//This set of functions are used to adjust the proportion in other mobile devices
getHeight(height) {
  return (height / defaultHeight) * appheight;
}

getWidth(width) {
  return (width / defaultWidth) * appwidth;
}

getCHeight(height) {
  return (height / defaultCHeight) * appcheight;
}

getCWidth(width) {
  return (width / defaultCWidth) * appcwidth;
}
