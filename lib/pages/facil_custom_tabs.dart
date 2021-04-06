import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onLoadStart(Uri url) async {
    //print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(Uri url) async {
    //print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(Uri url, int code, String message) {
    //print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    //print("\n\nBrowser closed!\n\n");
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback)
      : super(/*bFallback: browserFallback*/);

  @override
  void onOpened() {
    //print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    //print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    //print("ChromeSafari browser closed");
  }
}

class FacilCustomTabs {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new MyInAppBrowser());
  String url;

  FacilCustomTabs(String url) {
    this.url = url;
    /*browser.addMenuItem(new ChromeSafariBrowserMenuItem(
        id: 1,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
          print(url);
          print(title);
        }));*/
  }

  openTab() async {
    await browser.open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
            android:
                AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false),
            ios: IOSSafariOptions(barCollapsingEnabled: true)));
  }
}
