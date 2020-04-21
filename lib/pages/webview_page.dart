import 'dart:async';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onLoadStart(String url) async {
    //print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    //print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(String url, int code, String message) {
    //print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    //print("\n\nBrowser closed!\n\n");
  }
}

class FacilBrowser extends ChromeSafariBrowser {
  FacilBrowser(browserFallback) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    //print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    //print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    //print("ChromeSafari browser closed");
  }
}

class FacilWebView {
  final String transactionUrl;
  FacilWebView(this.transactionUrl);

  final ChromeSafariBrowser browser = new FacilBrowser(new MyInAppBrowser());

  Future<void> openWebView() {
    browser.open(
        url: "${this.transactionUrl}",
        options: ChromeSafariBrowserClassOptions(
            androidChromeCustomTabsOptions:
                AndroidChromeCustomTabsOptions(addShareButton: false),
            iosSafariOptions: IosSafariOptions(barCollapsingEnabled: true)));
    return null;
  }
}