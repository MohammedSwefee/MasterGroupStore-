import 'package:flutter/material.dart';

import '../../../widgets/home/search/custom_search.dart';
import 'header_type.dart';

class HeaderText extends StatelessWidget {
  final config;

  HeaderText({this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          config['height'] != null ? MediaQuery.of(context).size.height * config['height'] : 100,
      padding: EdgeInsets.only(
          top: config['padding'] ?? 20.0,
          left: config['padding'] ?? 20.0,
          right: config['padding'] ?? 15.0,
          bottom: 10.0),
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        bottom: false,
        top: config['isSafeArea'] == true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            HeaderType(config: config),
            if (config['showSearch'] == true)
              IconButton(
                icon: Icon(Icons.search),
                iconSize: 24.0,
                onPressed: () {
                  showSearch(context: context, delegate: CustomSearch());
                },
              )
          ],
        ),
      ),
    );
  }
}
