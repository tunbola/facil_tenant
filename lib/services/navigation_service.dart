import 'package:flutter/widgets.dart';

//NavigationService handles routing outside of the build context
class NavigationService {
  
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  bool goBack() {
    return navigatorKey.currentState.pop();
  }
}