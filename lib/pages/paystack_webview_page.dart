import 'dart:async';

import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayStackWebViewPage extends StatefulWidget {
  final String transactionUrl;
  PayStackWebViewPage(this.transactionUrl);
  @override
  _PayStackWebViewPage createState() => _PayStackWebViewPage();
}

class _PayStackWebViewPage extends State<PayStackWebViewPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        pageTitle: ValueNotifier("Payment gateway"),
        child: Builder(
          builder: (BuildContext context) {
            return Center(
              child: WebView(
                gestureNavigationEnabled: true,
                onPageStarted: (String url) {
                  return Center(
                    child: AppSpinner(),
                  );
                },
                onPageFinished: (String url) {},
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: "${widget.transactionUrl}",
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
              ),
            );
          },
        ));
  }
}
