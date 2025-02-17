library flutterslidetoact;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

/// Slider call to action component
class SlideAction extends StatefulWidget {
  /// The size of the sliding icon
  final double sliderButtonIconSize;

  /// Tha padding of the sliding icon
  final double sliderButtonIconPadding;

  /// The offset on the y axis of the slider icon
  final double sliderButtonYOffset;

  /// If the slider icon rotates
  final bool sliderRotate;

  /// The child that is rendered instead of the default Text widget
  final Widget? child;

  /// The height of the component
  final double height;

  /// The color of the inner circular button, of the tick icon of the text.
  /// If not set, this attribute defaults to primaryIconTheme.
  final Color? innerColor;

  /// The color of the external area and of the arrow icon.
  /// If not set, this attribute defaults to accentColor from your theme.
  final Color? outerColor;

  /// The text showed in the default Text widget
  final String? text;

  /// Text style which is applied on the Text widget.
  ///
  /// By default, the text is colored using [innerColor].
  final TextStyle? textStyle;

  /// The borderRadius of the sliding icon and of the background
  final double borderRadius;

  /// Callback called on submit
  /// If this is null the component will not animate to complete
  final VoidCallback? onSubmit;

  /// Elevation of the component
  final double elevation;

  /// The widget to render instead of the default icon
  final Widget? sliderButtonIcon;

  /// The title of slider icon
  final Widget? sliderButtonTitle;

  /// The widget to render instead of the default submitted icon
  final Widget? submittedIcon;

  /// The duration of the animations
  final Duration animationDuration;

  /// If true the widget will be reversed
  final bool reversed;

  /// the alignment of the widget once it's submitted
  final Alignment alignment;

  /// one tap on the button callback
  final void Function()? onTap;

  /// double tap on the button callback
  final void Function()? onDoubleTap;

  /// Create a new instance of the widget
  const SlideAction({
    Key? key,
    this.sliderButtonIconSize = 24,
    this.sliderButtonIconPadding = 16,
    this.sliderButtonYOffset = 0,
    this.sliderRotate = true,
    this.height = 70,
    this.outerColor,
    this.borderRadius = 52,
    this.elevation = 6,
    this.animationDuration = const Duration(milliseconds: 300),
    this.reversed = false,
    this.alignment = Alignment.center,
    this.submittedIcon,
    this.sliderButtonTitle,
    this.onSubmit,
    this.child,
    this.innerColor,
    this.text,
    this.textStyle,
    this.sliderButtonIcon,
    this.onTap,
    this.onDoubleTap,
  }) : super(key: key);

  @override
  SlideActionState createState() => SlideActionState();
}

/// Use a GlobalKey to access the state. This is the only way to call [SlideActionState.reset]
class SlideActionState extends State<SlideAction> with TickerProviderStateMixin {
  late AnimationController _sliderAnimationController;
  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _sliderKey = GlobalKey();
  double _dx = 0;
  double _maxDx = 0;
  // double _sliderWidth = 0.0;

  double get _progress => _dx == 0 ? 0 : _dx / _maxDx;
  double _endDx = 0;
  double _dz = 1;
  double? _containerWidth;
  double _checkAnimationDx = 0;
  bool submitted = false;
  late AnimationController _checkAnimationController,
      _shrinkAnimationController,
      _resizeAnimationController,
      _cancelAnimationController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(widget.reversed ? pi : 0),
        child: Container(
          key: _containerKey,
          height: widget.height,
          width: _containerWidth,
          constraints: _containerWidth != null ? null : BoxConstraints.expand(height: widget.height),
          child: Material(
            elevation: widget.elevation,
            color: widget.outerColor ?? Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: submitted
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(widget.reversed ? pi : 0),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.antiAlias,
                        children: <Widget>[
                          // widget.submittedIcon ??
                          //     Icon(
                          //       Icons.done,
                          //       color: widget.innerColor ??
                          //           Theme.of(context).primaryIconTheme.color,
                          //     ),
                          Positioned.fill(
                            right: 0,
                            child: Transform(
                              transform: Matrix4.rotationY(_checkAnimationDx * (pi / 2)),
                              alignment: Alignment.centerRight,
                              child: Container(
                                color: widget.outerColor ?? Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Opacity(
                        opacity: 1 - 1 * _progress,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(widget.reversed ? pi : 0),
                          child: widget.child ??
                              Text(
                                widget.text ?? 'Slide to act',
                                textAlign: TextAlign.center,
                                style: widget.textStyle ??
                                    TextStyle(
                                      color: widget.innerColor ?? Theme.of(context).primaryIconTheme.color,
                                      fontSize: 24,
                                    ),
                              ),
                        ),
                      ),
                      Positioned(
                        left: widget.sliderButtonYOffset,
                        child: Transform.scale(
                          scale: _dz,
                          origin: Offset(_dx, 0),
                          child: Transform.translate(
                            offset: Offset(_dx, 0),
                            child: Container(
                              key: _sliderKey,
                              child: GestureDetector(
                                onTap: () async {
                                  // await Future.delayed(Duration.zero, () {
                                  //   setState(() {
                                  //     _dx = (_dx + 25).clamp(0.0, _maxDx);
                                  //   });
                                  // });
                                  // await Future.delayed(Duration.zero, () {
                                  //   setState(() {
                                  //     _endDx = _dx;
                                  //   });
                                  // });
                                  // _cancelAnimation();
                                  _sliderAnimationController
                                      .reverse()
                                      .whenComplete(() => _sliderAnimationController.forward());
                                  if (widget.onTap != null) {
                                    widget.onTap!.call();
                                  }
                                },
                                onDoubleTap: widget.onDoubleTap,
                                onHorizontalDragUpdate: onHorizontalDragUpdate,
                                onHorizontalDragEnd: (details) async {
                                  _endDx = _dx;
                                  if (_progress <= 0.95 || widget.onSubmit == null) {
                                    _cancelAnimation();
                                  } else {
                                    // await _resizeAnimation();
                                    // await _shrinkAnimation();
                                    widget.onSubmit!();
                                    await _checkAnimation();
                                    await _cancelAnimation();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Center(
                                    child: SlideInRight(
                                      duration: const Duration(milliseconds: 400),
                                      from: MediaQuery.of(context).size.width / 6,
                                      controller: (p0) => _sliderAnimationController = p0,
                                      child: Container(
                                        height: widget.height - 10,
                                        decoration: BoxDecoration(
                                          color: widget.innerColor,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Row(
                                            children: [
                                              Transform.rotate(
                                                angle: widget.sliderRotate ? -pi * _progress : 0,
                                                child: widget.sliderButtonIcon ?? Container(),
                                              ),
                                              const SizedBox(width: 15),
                                              widget.sliderButtonTitle ?? Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Icon(
                                    //   Icons.arrow_forward,
                                    //   size: widget.sliderButtonIconSize,
                                    //   color: widget.outerColor ??
                                    //       Theme.of(context).colorScheme.secondary,
                                    // ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dx = (_dx + details.delta.dx).clamp(0.0, _maxDx);
    });
  }

  /// Call this method to revert the animations
  Future reset() async {
    await _checkAnimationController.reverse().orCancel;

    submitted = false;

    await _shrinkAnimationController.reverse().orCancel;

    await _resizeAnimationController.reverse().orCancel;

    await _cancelAnimation();
  }

  Future _checkAnimation() async {
    _checkAnimationController.reset();

    final animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkAnimationController,
      curve: Curves.slowMiddle,
    ));

    animation.addListener(() {
      if (mounted) {
        setState(() {
          _checkAnimationDx = animation.value;
        });
      }
    });
    await _checkAnimationController.forward().orCancel;
  }

  // Future _shrinkAnimation() async {
  //   _shrinkAnimationController.reset();
  //
  //   final diff = _initialContainerWidth! - widget.height;
  //   final animation = Tween<double>(
  //     begin: 0,
  //     end: 1,
  //   ).animate(CurvedAnimation(
  //     parent: _shrinkAnimationController,
  //     curve: Curves.easeOutCirc,
  //   ));
  //
  //   animation.addListener(() {
  //     if (mounted) {
  //       setState(() {
  //         _containerWidth = _initialContainerWidth! - (diff * animation.value);
  //       });
  //     }
  //   });
  //
  //   setState(() {
  //     submitted = true;
  //   });
  //   await _shrinkAnimationController.forward().orCancel;
  // }

  // Future _resizeAnimation() async {
  //   _resizeAnimationController.reset();
  //
  //   final animation = Tween<double>(
  //     begin: 0,
  //     end: 1,
  //   ).animate(CurvedAnimation(
  //     parent: _resizeAnimationController,
  //     curve: Curves.easeInBack,
  //   ));
  //
  //   animation.addListener(() {
  //     if (mounted) {
  //       setState(() {
  //         _dz = 1 - animation.value;
  //       });
  //     }
  //   });
  //   await _resizeAnimationController.forward().orCancel;
  // }

  Future _cancelAnimation() async {
    _cancelAnimationController.reset();
    final animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _cancelAnimationController,
      curve: Curves.bounceOut,
    ));

    animation.addListener(() {
      if (mounted) {
        setState(() {
          _dx = (_endDx - (_endDx * animation.value));
        });
      }
    });
    _cancelAnimationController.forward().orCancel;
  }

  @override
  void initState() {
    super.initState();

    _sliderAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _cancelAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _checkAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _shrinkAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _resizeAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox containerBox = _containerKey.currentContext!.findRenderObject() as RenderBox;
      _containerWidth = containerBox.size.width;
      // _initialContainerWidth = _containerWidth;

      final RenderBox sliderBox = _sliderKey.currentContext!.findRenderObject() as RenderBox;
      final sliderWidth = sliderBox.size.width;

      _maxDx = _containerWidth! - (sliderWidth) - widget.sliderButtonYOffset;
      // _maxDx = widget.maxDx;
    });
  }

  @override
  void dispose() {
    _cancelAnimationController.dispose();
    _checkAnimationController.dispose();
    _shrinkAnimationController.dispose();
    _resizeAnimationController.dispose();
    super.dispose();
  }
}
