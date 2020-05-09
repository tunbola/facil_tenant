import 'package:facil_tenant/services/access_service.dart';
import 'package:flutter/widgets.dart';

//NavigationService handles routing outside of the build context
class NavigationService {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arg}) async {
    await AccessService.saveLastVisitedRoute(routeName);
    return navigatorKey.currentState.pushNamed(routeName, arguments: arg);
  }

  Future<dynamic> navigateToReplace(String routeName, {dynamic arg}) async {
    await AccessService.saveLastVisitedRoute(routeName);
    return navigatorKey.currentState
        .pushReplacementNamed(routeName, arguments: arg);
  }

  Future<dynamic> removeAllExcept(String routeName, {dynamic arg}) async {
    await AccessService.saveLastVisitedRoute(routeName);
    return navigatorKey.currentState.pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arg);
  }

  bool goBack() {
    return navigatorKey.currentState.pop();
  }
}
