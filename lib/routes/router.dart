import 'package:facil_tenant/pages/paystack_webview_page.dart';
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
      return MaterialPageRoute(builder: (context) => DashboardPage());
    case routes.Messages:
      return MaterialPageRoute(builder: (context) => MessagesPage());
    case routes.MessagesByTitle:
      var params = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => MessagesByTitlePage(params));
    case routes.Notifications:
      return MaterialPageRoute(builder: (context) => NotificationsPage());
    case routes.Announcements:
      return MaterialPageRoute(builder: (context) => NotificationsPage(isAnnouncements: true));
    case routes.Complaints:
      return MaterialPageRoute(builder: (context) => NotificationsPage(isRequests: true));
    case routes.CreateRequest:
      return MaterialPageRoute(builder: (context) => RequestsPage());
    case routes.PaymentHistory:
      return MaterialPageRoute(builder: (context) => PaymentHistoryPage());
    case routes.OutstandingBills:
      return MaterialPageRoute(builder: (context) => OutstandingBillsPage());
    case routes.UserProfile:
      return MaterialPageRoute(builder: (context) => ProfilePage());
    case routes.ChatHistory:
      var params = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (context) => ChatHistoryPage(params));
    case routes.Paystack:
      var transactionKey = settings.arguments as String;
      return MaterialPageRoute(builder: (context) => PayStackWebViewPage(transactionKey));
    default:
      return MaterialPageRoute(builder: (context) => DashboardPage());
  }
}