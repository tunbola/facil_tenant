import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class PayStackWebViewPage extends StatefulWidget {
  @override
  _PayStackWebViewPage createState() => _PayStackWebViewPage();
}

class _PayStackWebViewPage extends State<PayStackWebViewPage> {
  String _pubKey = "pk_test_ea57ab81b641e03929a375c0dab3bdb38a922d57";

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      pageTitle: ValueNotifier("Payment gateway"),
      child: Center(
        child: WebviewScaffold(
        url: Uri.dataFromString('''
          <html>
            <head>
              <meta name="viewport" content="width=device-width">
            </head>
            <center>
              <body>
                <div>$_pubKey</div>
                <form action="" method="POST" >
                  <script
                    src="https://js.paystack.co/v1/inline.js" 
                    data-key="$_pubKey"
                    data-email="customer@gmail.com"
                    data-amount="10000"
                  ></script>
                </form>
              </body>
            </center>
          </html>
        ''', mimeType: 'text/html').toString(),
      ),
      )
    );
  }
}
