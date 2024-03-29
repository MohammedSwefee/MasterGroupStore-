import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';

class VideoController extends StatefulWidget {
  final controller;

  VideoController({this.controller});

  @override
  _VideoControllerState createState() => _VideoControllerState();
}

class _VideoControllerState extends State<VideoController> {
  var _duration;
  double _loading = 0.0;
  bool _pause;

  void setPause(bool value) {
    setState(() {
      _pause = value;
    });
    value ? widget.controller.pause() : widget.controller.play();
  }

  @override
  void initState() {
    //widget.controller.addListener(_listener);
    Timer.periodic(Duration(seconds: 1), (callback){
      if (widget.controller.position != null && widget.controller.value.duration!=null){
        _listener();
      }
    });
    _pause = !widget.controller.value.isPlaying;
    super.initState();
  }

  _listener() {
    setState(() {
      _duration = widget.controller.value.duration;
      _loading =
          widget.controller.value.position.inSeconds / widget.controller.value.duration.inSeconds;
      _pause = !widget.controller.value.isPlaying ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _position = widget.controller.value.position;
    String _durationString = _position != null && _duration != null
        ? "${_position.inMinutes % 60}:${_position.inSeconds % 60} / ${_duration.inMinutes % 60}:${_duration.inSeconds % 60}"
        : "";

    return Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.black87,
        child: Column(
          children: <Widget>[
            FittedBox(
              child: GestureDetector(
                onTapUp: (detail) {
                  double size = MediaQuery.of(context).size.width - 10;
                  double position = detail.globalPosition.dx - 10;
                  int time = _duration.inMilliseconds;
                  time = (time * (position / size)).toInt();
                  widget.controller.seekTo(Duration(milliseconds: time));
                },
                child: LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(0),
                  lineHeight: 2.0,
                  linearStrokeCap: LinearStrokeCap.butt,
                  percent: _loading,
                  progressColor: Colors.red,
                ),
              ),
              fit: BoxFit.fill,
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.0, top: 2, bottom: 2),
                      child: Icon(
                        _pause ? Icons.play_arrow : Icons.pause,
                        color: Theme.of(context).backgroundColor.withOpacity(0.8),
                        size: 18.0,
                      ),
                    ),
                    onTap: () => setPause(!_pause)),
                SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Text(
                    _durationString,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      height: 1.2,
                      fontFamily: kCssFontFamily,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: GestureDetector(
                    child: Icon(
                      Icons.replay,
                      color: Theme.of(context).backgroundColor,
                      size: 16,
                    ),
                    onTap: () {
                      widget.controller.seekTo(
                        Duration(seconds: 0),
                      );
                    },
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
