import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/wishlist.dart';

class HeartButton extends StatefulWidget {
  final Product product;
  final double size;
  final Color color;

  HeartButton({this.product, this.size, this.color});

  @override
  _HeartButtonState createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  @override
  Widget build(BuildContext context) {
    List<Product> wishlist = Provider.of<WishListModel>(context).getWishList();
    final isExist = wishlist.firstWhere((item) => item.id == widget.product.id, orElse: () => null);

    if (isExist == null) {
      return IconButton(
        onPressed: () {
          Provider.of<WishListModel>(context).addToWishlist(widget.product);
          setState(() {});
        },
        icon: Icon(FontAwesomeIcons.heart, color: widget.color, size: widget.size ?? 16.0),
      );
    }

    return IconButton(
      onPressed: () {
        Provider.of<WishListModel>(context).removeToWishlist(widget.product);
        setState(() {});
      },
      icon: Icon(FontAwesomeIcons.solidHeart, color: widget.color, size: widget.size ?? 16.0),
    );
  }
}
