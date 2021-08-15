import 'package:flutter/material.dart';



class dial extends State<dialer> with TickerProviderStateMixin {
  Color backgroundColor;
  List<dialChild> children;
  dial({this.backgroundColor, this.children});

  AnimationController _controller;

  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speed = new Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: new List.generate(children.length, (
        int index,
      ) {
        Widget child = new Container(
          padding: EdgeInsets.only(right: 4),
          alignment: FractionalOffset.bottomRight,
          margin: EdgeInsets.only(bottom: 10),
          child: new ScaleTransition(
              alignment: Alignment(0.6, 1),
              scale: new CurvedAnimation(
                parent: _controller,
                curve: new Interval(
                    0, (1 / children.length) * (children.length - index),
                    curve: Curves.ease),
              ),
              child: children[index]),
        );
        return child;
      }).toList()
        ..add(
          new FloatingActionButton(
            heroTag: null,
            backgroundColor: backgroundColor,
            child: new AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(_controller.value * 2.355),
                  alignment: FractionalOffset.center,
                  child: new Icon(Icons.add),
                );
              },
            ),
            onPressed: () {
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
    );

    return speed;
  }
}

class child extends State<dialChild> {
  @override
  Widget build(BuildContext context) {
    Widget c = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(5),
          ),
          margin: EdgeInsets.only(bottom: 14, right: 8),
          child: new Text(
            widget.text,
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        new FloatingActionButton(
          heroTag: null,
          mini: true,
          backgroundColor: widget.backgroundColor,
          child: new Icon(widget.icon, color: widget.iconColor),
          onPressed: () {
            widget.onPressed();
          },
        ),
      ],
    );

    return c;
  }
}

class dialer extends StatefulWidget {
  Color backgroundColor;
  List<dialChild> children;
  dialer({this.backgroundColor: Colors.lightGreen, this.children});

  @override
  State createState() =>
      new dial(backgroundColor: this.backgroundColor, children: children);
}

class dialChild extends StatefulWidget {
  Color backgroundColor, iconColor;
  String text;
  IconData icon;
  void Function() onPressed;

  dialChild(
      {this.text: "",
      this.icon,
      this.backgroundColor: Colors.lightGreen,
      this.iconColor: Colors.white,
      this.onPressed});

  @override
  State createState() => new child();
}
