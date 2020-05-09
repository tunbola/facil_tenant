import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes; //import routes

//import app pages
import 'package:facil_tenant/pages/auth_page.dart';
import 'package:facil_tenant/pages/dashboard_page.dart';
import 'package:facil_tenant/pages/request_create_page.dart';
import 'package:facil_tenant/pages/notifications_page.dart';
import 'package:facil_tenant/pages/outstanding_bills.dart';
import 'package:facil_tenant/pages/payment_history_page.dart';
import 'package:facil_tenant/pages/profile_page.dart';
import "package:facil_tenant/pages/onboarding_page.dart";
import 'package:facil_tenant/pages/chat_history_page.dart';
import 'package:facil_tenant/pages/messages_by_title_page.dart';
import 'package:facil_tenant/pages/messages_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case routes.Onboarding:
      return MaterialPageRoute(builder: (context) => OnboardingPage());
    case routes.Auth:
      return MaterialPageRoute(builder: (context) => AuthPage());
    case routes.Home:
      return CupertinoPageRoute(builder: (context) => DashboardPage());
    case routes.Messages:
      return CupertinoPageRoute(builder: (context) => MessagesPage());
    case routes.MessagesByTitle:
      var params = settings.arguments as Map<String, dynamic>;
      return CupertinoPageRoute(builder: (context) => MessagesByTitlePage(params));
    case routes.Notifications:
      return CupertinoPageRoute(builder: (context) => NotificationsPage());
    case routes.Announcements:
      return CupertinoPageRoute(builder: (context) => NotificationsPage(isAnnouncements: true));
    case routes.Requests:
      return CupertinoPageRoute(builder: (context) => NotificationsPage(isRequests: true));
    case routes.CreateRequest:
      return CupertinoPageRoute(builder: (context) => RequestsPage());
    case routes.PaymentHistory:
      return CupertinoPageRoute(builder: (context) => PaymentHistoryPage());
    case routes.OutstandingBills:
      return CupertinoPageRoute(builder: (context) => OutstandingBillsPage());
    case routes.UserProfile:
      return CupertinoPageRoute(builder: (context) => ProfilePage());
    case routes.ChatHistory:
      var params = settings.arguments as Map<String, dynamic>;
      return CupertinoPageRoute(builder: (context) => ChatHistoryPage(params));
    default:
      return CupertinoPageRoute(builder: (context) => DashboardPage());
  }
}