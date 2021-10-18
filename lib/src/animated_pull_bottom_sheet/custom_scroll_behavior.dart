import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MenuMode { DrawerMode, PullMenuMode }
enum _FlingGestureKind { none, fling_down, fling_up }
const double _kMinFlingVelocity = 700.0;
const _kGreyOpacity = Color.fromRGBO(129, 129, 129, 0.5);
const _kTransitionDuration = Duration(milliseconds: 300);

_FlingGestureKind _describeFlingGesture(double velocity) {
  final double vy = velocity;
  if (vy.abs() < _kMinFlingVelocity) return _FlingGestureKind.none;
  if (vy < 0)
    return _FlingGestureKind.fling_down;
  else if (vy > 0)
    return _FlingGestureKind.fling_up;
  else
    return _FlingGestureKind.none;
}

class PullSheetPickerWidget extends StatefulWidget {
  final double dismissThreshold;

  final BuildContext? context;

  final Widget? child;

  final String? title;
  final bool showTitle;

  final Function? onEmptySpaceTabbed;
  final MenuMode menuMode;

  const PullSheetPickerWidget({
    Key? key,
    this.dismissThreshold = 50,
    this.context,
    this.child,
    this.title,
    this.showTitle = false,
    this.onEmptySpaceTabbed,
    this.menuMode = MenuMode.PullMenuMode,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PullSheetPickerWidgetState(context);
  }
}

class PullSheetPickerWidgetState extends State<PullSheetPickerWidget> {
  double? maxHeight;
  bool motionUnderway = false;
  Duration duration = Duration.zero;
  Curve curve = Curves.linear;
  ScrollPhysics? scrollPhysics;

  late double minHeight;
  late double height;

  PullSheetPickerWidgetState(context) {
    minHeight = kIsWeb ? MediaQuery.of(context).size.height * 0.6 : 240;
    height = minHeight;
    maxHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    this.scrollPhysics = _CustomScrollPhysics(countryPickerWidgetState: this);
  }

  changeHeightWhenDragged(double offset) {
    setState(() {
      height += offset;
    });
  }

  void maximizeSheetHeight() {
    setState(() {
      motionUnderway = true;
      duration = _kTransitionDuration;
      curve = Curves.ease;
      height = maxHeight ?? minHeight;
    });
    Future.delayed(_kTransitionDuration, () {
      setState(() {
        motionUnderway = false;
        duration = Duration.zero;
        curve = Curves.linear;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void minimizeSheetHeight() {
    setState(() {
      motionUnderway = true;
      duration = _kTransitionDuration;
      curve = Curves.ease;
      height = minHeight;
    });
    Future.delayed(_kTransitionDuration, () {
      setState(() {
        motionUnderway = false;
        duration = Duration.zero;
        curve = Curves.elasticOut;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(title: Text("A"));
    return Padding(
      padding: EdgeInsets.only(top: _appBar.preferredSize.height),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            GestureDetector(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: _kGreyOpacity,
              ),
              onTap: widget.onEmptySpaceTabbed as void Function()?,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                elevation: 10,
                child: SafeArea(
                  top: false,
                  child: RepaintBoundary(
                    child: AnimatedContainer(
                      color: Theme.of(context).cardColor,
                      duration: duration,
                      curve: curve,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          widget.showTitle
                              ? Padding(
                                  child: Text(
                                    widget.title!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  padding: EdgeInsets.only(top: 12, left: 12),
                                )
                              : SizedBox(height: 0, width: 0),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: _CustomScrollBehavior(),
                              child: SingleChildScrollView(
                                physics: scrollPhysics,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ],
                      ),
                      height: height,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class _CustomScrollPhysics extends ScrollPhysics {
  final PullSheetPickerWidgetState? countryPickerWidgetState;

  const _CustomScrollPhysics(
      {this.countryPickerWidgetState, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  _CustomScrollPhysics applyTo(ScrollPhysics? ancestor) => _CustomScrollPhysics(
      countryPickerWidgetState: countryPickerWidgetState,
      parent: buildParent(ancestor));

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (countryPickerWidgetState!.height >=
        countryPickerWidgetState!.maxHeight!) {
      if (offset.sign == 1.0 && position.atEdge && position.pixels == 0.0) {
        this.countryPickerWidgetState!.changeHeightWhenDragged(-offset);
        return 0;
      }
      return super.applyPhysicsToUserOffset(position, offset);
    } else {
      this.countryPickerWidgetState!.changeHeightWhenDragged(-offset);
      return 0;
    }
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (_describeFlingGesture(velocity) == _FlingGestureKind.fling_up) {
      if (position.pixels == 0.0 &&
          countryPickerWidgetState!.height <
              countryPickerWidgetState!.maxHeight!) {
        countryPickerWidgetState!.maximizeSheetHeight();
        return null;
      }
    } else if (_describeFlingGesture(velocity) ==
        _FlingGestureKind.fling_down) {
      if (position.pixels == 0) {
        this.countryPickerWidgetState!.minimizeSheetHeight();
        return null;
      }
    } else if (_describeFlingGesture(velocity) == _FlingGestureKind.none) {
      double dismissThreshold =
          countryPickerWidgetState!.widget.dismissThreshold;
      if (position.pixels == 0 &&
          !this.countryPickerWidgetState!.motionUnderway) {
        var maxMinHeightDifference = (countryPickerWidgetState!.maxHeight! -
            countryPickerWidgetState!.minHeight);
        var offset = (countryPickerWidgetState!.height -
            countryPickerWidgetState!.minHeight);

        if (((offset / maxMinHeightDifference) * 100) > dismissThreshold &&
            countryPickerWidgetState!.height !=
                countryPickerWidgetState!.maxHeight)
          countryPickerWidgetState!.maximizeSheetHeight();
        else if (((offset / maxMinHeightDifference) * 100) <=
                dismissThreshold &&
            countryPickerWidgetState!.height !=
                countryPickerWidgetState!.minHeight)
          countryPickerWidgetState!.minimizeSheetHeight();

        return null;
      }
    }

    var result = super.createBallisticSimulation(position, velocity);
    if (result.runtimeType == ClampingScrollSimulation &&
        velocity.abs() > 0 &&
        velocity.abs() < _kMinFlingVelocity) {
      return null;
    }
    return result;
  }
}
