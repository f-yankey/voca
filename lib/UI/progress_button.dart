// import 'dart:async';
// import 'package:flutter/material.dart';

// class ProgressButton extends StatefulWidget {
  
//    final Function callback;

//    ProgressButton(this.callback);

//   _ProgressButtonState createState() => _ProgressButtonState();
// }

// class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {
 
// AnimationController _animationController;
// Animation _animation;
// bool _isPressed = false, _animatingReveal = false;
// int _state = 0;
// double _width = double.infinity;
// GlobalKey _globalKey = GlobalKey();

//   @override
//   void deactivate() {
//     reset();
//     super.deactivate();
//   }

//   @override
//   dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }


//    @override
//   Widget build(BuildContext context) {
//     return PhysicalModel(
//         color: Colors.blue,
//         elevation: calculateElevation(),
//         borderRadius: BorderRadius.circular(25.0),
//         child: Container(
//           key: _globalKey,
//           height: 48.0,
//           width: _width,
//           child: RaisedButton(
//             padding: EdgeInsets.all(0.0),
//             color: _state == 2 ? Colors.white : Colors.blue,
//             shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
//             child: buildButtonChild(),
//             onPressed: () {},
//             onHighlightChanged: (isPressed) {
//               setState(() {
//                 _isPressed = isPressed;
//                 if (_state == 0) {
//                   animateButton();
//                 }
//               });
//             },
//           ),
//         ));
//   }

//    void animateButton() {
//     double initialWidth = _globalKey.currentContext.size.width;

//     _animationController =
//         AnimationController(duration: Duration(milliseconds: 300), vsync: this);
//     _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
//       ..addListener(() {
//         setState(() {
//           _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
//         });
//       });
//     _animationController.forward();

//     setState(() {
//       _state = 1;
//     });

//     Timer(Duration(milliseconds: 3300), () {
//       setState(() {
//         _state = 2;
//       });
//     });

//     Timer(Duration(milliseconds: 3600), () {
//       _animatingReveal = true;
//       //widget.callback();
//     });
//   }

//    Widget buildButtonChild() {
//     if (_state == 0) {
//       return Text(
//         'Finish!',
//         style: TextStyle(color: Colors.white, fontSize: 16.0),
//       );
//     } else if (_state == 1) {
//       return SizedBox(
//         height: 36.0,
//         width: 36.0,
//         child: CircularProgressIndicator(
//           value: null,
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
//         ),
//       );
//     } else {
//       return Icon(Icons.check, color: Colors.blue);
//     }
//   }

//   double calculateElevation() {
//     if (_animatingReveal) {
//       return 0.0;
//     } else {
//       return _isPressed ? 6.0 : 4.0;
//     }
//   }

//   void reset() {
//     _width = double.infinity;
//     _animatingReveal = false;
//     _state = 0;
//   }

// }


import 'package:flutter/material.dart';
import 'dart:async';
import '../models/voca_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressButton extends StatefulWidget {
  
  //Class variables
  VocaUser newUser;
  BuildContext context;
  final Function callback;

  ProgressButton(this.callback,this.newUser,this.context);

  @override
  State<StatefulWidget> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> with TickerProviderStateMixin {

  VocaUser _newUser;
  BuildContext _context;
  bool _isPressed = false, _animatingReveal = false;
  int _state = 0;
  double _width = double.infinity;
  Animation _animation;
  GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  
  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

   validationDialog(BuildContext context){
          return showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context){
              return new AlertDialog(
                title: Text('Error!'),
                content: Text('Some fields are empty!', style:TextStyle(fontSize: 20.0)),
                contentPadding: EdgeInsets.all(10.0),
                actions: <Widget>[
                  new FlatButton(
                    child: Text('Ok'),
                    onPressed: (){
                      Navigator.of(context).pop();
                    }
                  )
                ],
              );  
            } 
          );
    }

   initializeWidget(){
      _newUser = widget.newUser;
      _context = widget.context;
    }

   addNewUser(){
      if(_newUser.firstName == null || _newUser.lastName == null || _newUser.age == null)
      {
        validationDialog(_context);
      }
      else
      {
        //Let's animate the button if the user is not null
          animateButton();

          Firestore.instance.collection('VocaUsers').add({
          'Age' : _newUser.age,
          'FirstName': _newUser.firstName,
          'LastName':_newUser.lastName,
          'PhoneNumber': '+233500008264'//'+233271770255'_newUser.phoneNumber
          }).then((value){
            
            finalAnimationMoment();
            //Navigator.of(context).pushReplacementNamed('/homepage');
          }).catchError((e){
            print(e);
          });
      }  
  }

  finalAnimationMoment(){
      setState(() {
          _state = 2;
        });

         _animatingReveal = true;
        widget.callback();

      //   Timer(Duration(milliseconds: 3600), () {
      //   _animatingReveal = true;
      //   widget.callback();
      // });
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
            color: _state == 2 ? Colors.green : Colors.blue,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: buildButtonChild(),
            onPressed: () {},
            onHighlightChanged: (isPressed) {
              setState(() {
                _isPressed = isPressed;
                if (_state == 0) {
                  initializeWidget();
                  addNewUser();    
                }
              });
            },
          ),
        ));
  }

 
  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    // Timer(Duration(milliseconds: 3300), () {
    //   setState(() {
    //     _state = 2;
    //   });
    // });

    // Timer(Duration(milliseconds: 3600), () {
    //   _animatingReveal = true;
    //   widget.callback();
    // });
  }

  Widget buildButtonChild() {
    if (_state == 0) {
      return Text(
        'Finish!',
        style: TextStyle(color: Colors.white, fontSize: 16.0),
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