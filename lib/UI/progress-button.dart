import 'dart:async';
import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  
  // final Function callback;

  // ProgressButton(this.callback);

  _ProgressButtonState createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {
 
AnimationController _animationController;
Animation _animation;
bool _isPressed = false,_animatingReveal = false;
int _state = 0;
double _width = double.infinity;
GlobalKey _globalKey = GlobalKey();

  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }


   @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: Colors.blue,
        elevation: calculateElevation(),
        borderRadius: BorderRadius.circular(25.0),
        child: Container(
          key: _globalKey,
          height: 48.0,
          width: _width,
          child: RaisedButton(
            padding: EdgeInsets.all(0.0),
            color: _state == 2 ? Colors.blueAccent : Colors.white,
            child: buildButtonChild(),
            onPressed: () {},
            onHighlightChanged: (isPressed) {
              setState(() {
                _isPressed = isPressed;
                if (_state == 0) {
                  animateButton();
                }
              });
            },
          ),
        ));
  }

   void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
        });
      });
    _animationController.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _state = 2;
      });
    });

    Timer(Duration(milliseconds: 3600), () {
      _animatingReveal = true;
      //widget.callback();
    });
  }

   Widget buildButtonChild() {
    if (_state == 0) {
      return Text(
        'Finish!',
        style: TextStyle(color: Colors.blueAccent, fontSize: 16.0),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36.0,
        width: 36.0,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  double calculateElevation() {
    if (_animatingReveal) {
      return 0.0;
    } else {
      return _isPressed ? 6.0 : 4.0;
    }
  }

  void reset() {
    _width = double.infinity;
    _animatingReveal = false;
    _state = 0;
  }

}