import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../widgets/home/search/custom_search.dart';

class Logo extends StatelessWidget {
  final config;

  Logo({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
          constraints: BoxConstraints(minHeight: 100),
          child: Stack(
            children: <Widget>[
              (config['showSearch'] ?? false)
                  ? Positioned(
                top: 55,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).accentColor.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () {
                    showSearch(context: context, delegate: CustomSearch());
                  },
                ),
              )
                  : Container(),
              Positioned(
                top: 55,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    Icons.blur_on,
                    color: Theme.of(context).accentColor.withOpacity(0.9),
                    size: 22,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              if (config['hideLogo'] == null || config['hideLogo'] == false)
                Center(
                  child: Padding(
                    child: Image.asset(kLogoImage, height: 40),
                    padding: EdgeInsets.only(bottom: 10.0, top: 60.0),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
