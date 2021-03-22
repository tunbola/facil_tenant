import 'package:flutter/material.dart';
import '../styles/colors.dart';

int _activePage = 0;

// class OnboardingPage extends StatefulWidget {
//  @override
//   State<StatefulWidget> createState() {
//     return _OnboardingPageState();
//   }
// }

class OnboardingPage extends StatelessWidget {
  final PageController _ctrl = PageController(initialPage: 0);
  final ValueNotifier _activeSlide = ValueNotifier(_activePage);

  // @override
  // void initState() {
  //   super.initState();
  //   _ctrl = PageController(initialPage: 0);
  //   _activeSlide = ValueNotifier(_activePage);
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _ctrl.dispose();
  //   _activeSlide.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          PageView(
            controller: _ctrl,
            onPageChanged: (val) {
              _activePage = val;
              _activeSlide.value = val;
            },
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/media.png'),
                    alignment: Alignment.center,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    "",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/successful_payment.png'),
                    alignment: Alignment.center,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    "",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/receipt.png'),
                    alignment: Alignment.center,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: 80.0,
                  left: 14.0,
                  right: 14.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: Text(
                          "",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pushReplacementNamed("auth"),
                      child: Text("Get Started"),
                    )
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            width: MediaQuery.of(context).size.width * 0.9,
            bottom: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "NEXT",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onPressed: () => _ctrl.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _activeSlide,
                  builder: (context, val, child) {
                    return DotIndicator(
                      itemCount: 3,
                      activeIndex: val,
                    );
                  },
                ),
                FlatButton(
                  child: Text(
                    "SKIP",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  onPressed: () => _ctrl.animateToPage(2,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.slowMiddle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  final int itemCount;
  final int activeIndex;
  final Color inactiveColor;
  final Color activeColor;
  DotIndicator({
    this.itemCount = 3,
    this.activeIndex = 0,
    this.inactiveColor = Colors.black,
    this.activeColor = shedAppYellow300,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        itemCount,
        (it) {
          Color color = activeIndex == it ? activeColor : inactiveColor;
          return Container(
            margin: EdgeInsets.all(5.0),
            child: CircleAvatar(
              radius: 5.0,
              backgroundColor: color,
            ),
          );
        },
      ),
    );
  }
}
