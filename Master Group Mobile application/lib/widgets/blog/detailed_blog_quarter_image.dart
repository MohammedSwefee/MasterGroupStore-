import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../common/tools.dart';
import '../../models/blog.dart';

class OneQuarterImageType extends StatefulWidget {
  final Blog item;

  OneQuarterImageType({Key key, @required this.item}) : super(key: key);

  @override
  _OneQuarterImageTypeState createState() => _OneQuarterImageTypeState();
}

class _OneQuarterImageTypeState extends State<OneQuarterImageType> {
  ScrollController _scrollController;
  bool isExpandedListView = true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.offset == 0) {
      setState(() {
        isExpandedListView = true;
      });
    } else {
      setState(() {
        isExpandedListView = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    child: ListView(
                      controller: _scrollController,
                      children: <Widget>[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width - 30,
                                child: Stack(
                                  children: <Widget>[
                                    Hero(
                                      tag: 'blog-${widget.item.id}',
                                      child: Tools.image(
                                        url: widget.item.imageFeature,
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        size: kSize.medium,
                                      ),
                                      transitionOnUserGestures: true,
                                    ),
                                    Tools.image(
                                      url: widget.item.imageFeature,
                                      fit: BoxFit.cover,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3,
                                      size: kSize.large,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 5),
                          child: Text(
                            widget.item.title,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        HtmlWidget(
                          widget.item.content,
                          hyperlinkColor:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          textStyle: Theme.of(context).textTheme.body1.copyWith(
                              fontSize: 13.0,
                              height: 1.4,
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 90,
              child: AnimatedOpacity(
                opacity: isExpandedListView ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 180,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            child: Tools.getCachedAvatar(
                                'https://api.adorable.io/avatars/60/${widget.item.author}.png'),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'by ${widget.item.author} ',
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.item.date,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Container(
                  margin: EdgeInsets.all(12.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.0,
                    color: Theme.of(context).accentColor,
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
