import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReadfieldWidget extends StatelessWidget {
  const ReadfieldWidget(
    String label,
    String content,
  )   : _label = label,
        _content = content;

  final String _label;
  final String _content;

  @override
  Widget build(BuildContext context) {
    return  new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Container(
//          margin: EdgeInsets.only(top: 10.0),
              padding: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0),
              child: Text(
                _label,
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ),

            new Row (
              children: [
                new Expanded (
                  child:             new Container(
                      constraints: new BoxConstraints(
                        maxHeight: 100.0,
                      ),
                      padding: EdgeInsets.all(10.0),
                      //                       alignment: Alignment.topCenter,
                      //                 height: _height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(6.0) //         <--- border radius here
                        ),
                      ),
                      child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                        Flexible(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(_content)))
                      ])),
                )
              ],
            )

          ],
        );
  }
}
