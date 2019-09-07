import 'package:facil_tenant/pages/outstanding_bills.dart';
import 'package:facil_tenant/pages/payment_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facil_tenant/models/message_model.dart';
import 'package:facil_tenant/models/user_model.dart';

import 'package:facil_tenant/pages/notification_detail_page.dart';
import 'package:overlay_support/overlay_support.dart';

import 'styles/theme.dart';

import 'pages/splash_screen_page.dart';
import 'pages/auth_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/dashboard_page.dart';
import './pages/notifications_page.dart';
import './pages/notification_create_page.dart';
import './pages/profile_page.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        // showPerformanceOverlay: true,
        // debugShowMaterialGrid: true,
        title: 'Facil App',
        theme: shedAppThemeData(),
        home: const SplashPage(),
        routes: {
          'onboarding': (context) => OnboardingPage(),
          'auth': (context) => AuthPage(),
          'home': (context) => DashboardPage(),
          'notifications': (context) => NotificationsPage(),
          'announcements': (context) => NotificationsPage(isAnnouncements: true),
          'complaints': (context) => NotificationsPage(isComlaint: true,),
          'notifications/create': (context) => NotificationCreatePage(),
          'payment/history': (context) => PaymentHistoryPage(),
          'outstandings': (context) => OutstandingBillsPage(),
          'profile': (context) => ProfilePage(),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => DashboardPage(),
          );
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> path = settings.name.split('/');
          switch (path[0]) {
            case 'notifications':
              final data = MessageModel(
                id: "1",
                title: "My Roof Leaks",
                isRead: false,
                body:
                    """Harmful interruptions take a large toll. An average person gets interrupted many times an hour, has multiple windows open on their computer, checks their email repeatedly, feels that half of their time in meetings is unproductive, and spends a large part of their working time simply looking for the information they need to do their job.""",
                createdAt: DateTime.now(),
                to: "Dirisu Jesse",
                from: UserModel(
                  email: "tenant@facil.com",
                  picture: "assets/img/media.png",
                  type: UserType.TENANT,
                  name: "Ogbeni Ayalegbe",
                  phoneNumber: "+234 820 022 6425",
                ),
              );
              return MaterialPageRoute(
                builder: (BuildContext context) => NotificationDetailPage(
                  isFromMe: path[2] == 'true',
                  isAnnouncement: path[3] == 'true',
                  message: data,
                ),
              );
              break;
            default:
              return MaterialPageRoute(
                builder: (BuildContext context) => DashboardPage(),
              );
          }
        },
      ),
    );
  }
}
