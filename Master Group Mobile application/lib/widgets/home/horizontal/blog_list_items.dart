import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../models/app.dart';
import '../../../models/blog.dart';
import '../../../screens/blogs.dart';
import '../../../widgets/blog/blog_view.dart';
import 'package:fstore/widgets/home/header/header_view.dart';

class BlogListItems extends StatefulWidget {
  final config;

  BlogListItems({this.config});

  @override
  _BlogListItemsState createState() => _BlogListItemsState();
}

class _BlogListItemsState extends State<BlogListItems> {
  Future<List<Blog>> _fetchBlogs;

  @override
  void initState() {
    _fetchBlogs = getBlogs(); // only create the future once.
    super.initState();
  }

  Future<List<Blog>> getBlogs() async {
    List<Blog> blogs = [];
    var _jsons = await Blog.getBlogs(url: serverConfig['blog'], page: 1);
//    Provider.of<AppModel>(context).appConfig

    for (var item in _jsons) {
      blogs.add(Blog.fromJson(item));
    }
    return blogs;
  }

  Widget _buildHeader(context, blogs) {
    final locale = Provider.of<AppModel>(context).locale;
    if (widget.config.containsKey("name")) {
      var showSeeAllLink = widget.config['layout'] != "instagram";
      return HeaderView(
        headerText: widget.config["name"][locale] ?? '',
        showSeeAll: showSeeAllLink,
        callback: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogScreen(blogs: blogs),
            ),
          )
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var emptyPosts = [Blog.empty(1), Blog.empty(2), Blog.empty(3)];

    return Column(
      children: <Widget>[
        FutureBuilder<List<Blog>>(
          future: _fetchBlogs,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Column(
                  children: <Widget>[
                    _buildHeader(context, null),
                    BlogItemView(posts: emptyPosts, index: 0),
                    BlogItemView(posts: emptyPosts, index: 1),
                    BlogItemView(posts: emptyPosts, index: 2),
                  ],
                );
                break;
              case ConnectionState.done:
              default:
                if (snapshot.hasError) {
                  return Container();
                } else {
                  List<Blog> blogs = snapshot.data;
                  int length = blogs.length;
                  return Column(
                    children: <Widget>[
                      _buildHeader(context, blogs),
                      Container(
                        width: screenWidth,
                        height: screenWidth * 0.6,
                        color: Theme.of(context).cardColor.withOpacity(0.85),
                        padding: EdgeInsets.only(top: 8.0),
                        child: PageView(
                          children: [
                            for (var i = 0; i < length; i = i + 3)
                              Column(
                                children: <Widget>[
                                  blogs[i] != null ? Expanded(
                                    child: BlogItemView(posts: blogs, index: i),
                                  ) : Expanded(
                                    child: Container(),
                                  ),
                                  i + 1 < length ? Expanded(
                                    child: BlogItemView(posts: blogs, index: i + 1),
                                  ) : Expanded(
                                    child: Container(),
                                  ),
                                  i + 2 < length ? Expanded(
                                    child: BlogItemView(posts: blogs, index: i + 2),
                                  ) : Expanded(child: Container(),),
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ],
    );
  }
}
