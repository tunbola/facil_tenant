import 'package:flutter/material.dart';
import '../styles/colors.dart';

//class contains widget that's the navigation bar of the
//application
class AppScaffold extends StatelessWidget {
  final Widget child;
  final Widget bottom;
  final Widget floatingActionButton;
  final ValueNotifier pageTitle;
  final Widget bottomWidget;
  final bool auomaticallyImplyLeading;
  final List<Widget> actions;

  AppScaffold({
    @required this.child,
    @required this.pageTitle,
    this.actions = const [SizedBox(width: 0, height: 0)],
    this.bottomWidget = const SizedBox(height: 0),
    this.auomaticallyImplyLeading = true,
    this.bottom,
    this.floatingActionButton,
  }) : assert(child != null && pageTitle != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: bottom != null
            ? Theme.of(context).iconTheme.copyWith(color: Colors.white)
            : Theme.of(context).iconTheme,
        brightness: bottom != null ? Brightness.dark : Brightness.light,
        backgroundColor: bottom != null
            ? Theme.of(context).accentColor
            : Theme.of(context).primaryColor,
        automaticallyImplyLeading: auomaticallyImplyLeading,
        elevation: 0,
        title: Text(
          "FACIL",
          style: Theme.of(context).textTheme.headline.copyWith(
                color: bottom != null
                    ? Colors.white
                    : Theme.of(context).accentColor,
              ),
        ),
        actions: actions,
        bottom: bottom,
      ),
      body: Container(
        padding: EdgeInsets.all(0),
        margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/properties.png'),
            alignment: Alignment.bottomCenter, //push image to bottom of the screen and align to center on the x-axis
            fit: BoxFit.fitWidth,
            colorFilter: ColorFilter.mode(Colors.white10, BlendMode.dstATop),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            bottom == null
                ? SizedBox(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: shedAppBlue400,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ValueListenableBuilder(
                            valueListenable: pageTitle,
                            builder: (context, val, child) {
                              return Text(
                                val,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(
                                        color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          GestureDetector(
                            child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                AssetImage('assets/img/tenant.png'),
                            radius: 15.0,
                          ),
                          onTap: () => Navigator.of(context).pushNamed('profile'),
                          )
                        ],
                      ),
                    ),
                    height: 40.0,
                  )
                : SizedBox(
                    height: 0,
                  ),
            Expanded(
              child: child,
            ),
            bottomWidget,
          ],
        ),
      ),
    );
  }
}
