import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';

import '../../common/styles.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/tree_view.dart';

class CardCategories extends StatefulWidget {
  final List<Category> categories;

  CardCategories(this.categories);

  @override
  _StateCardCategories createState() => _StateCardCategories();
}

class _StateCardCategories extends State<CardCategories> with AfterLayoutMixin {
  ScrollController controller = ScrollController();
  double page;

  @override
  void initState() {
    page = 0.0;
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    controller.addListener(() {
      setState(() {
        page = _getPage(controller.position, screenSize.width * 0.30 + 10);
      });
    });
  }

  bool hasChildren(id) {
    return widget.categories.where((o) => o.parent == id).toList().length > 0;
  }

  double _getPage(ScrollPosition position, double width) {
    return position.pixels / width;
  }

  List<Category> getSubCategories(id) {
    return widget.categories.where((o) => o.parent == id).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _categories = widget.categories.where((item) => item.parent == 0).toList();

    return Container(
      height: MediaQuery.of(context).size.height - 150,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TreeView(
              parentList: List.generate(_categories.length, (index) {
                return Parent(
                  parent: CategoryCardItem(
                    _categories[index],
                    hasChildren: hasChildren(_categories[index].id),
                    offset: page - index,
                  ),
                  childList: ChildList(
                    children: [
                      for (var category in getSubCategories(_categories[index].id))
                        Parent(
                          parent: SubItem(category),
                          childList: ChildList(
                            children: [
                              for (var cate in getSubCategories(category.id))
                                Parent(
                                  parent: SubItem(cate, isLast: true),
                                  childList: ChildList(
                                    children: <Widget>[],
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCardItem extends StatelessWidget {
  final Category category;
  final bool hasChildren;
  final offset;

  CategoryCardItem(this.category, {this.hasChildren = false, this.offset});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: hasChildren
          ? null
          : () {
              Product.showList(context: context, cateId: category.id, cateName: category.name);
            },
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          height: screenSize.width * 0.35,
          padding: EdgeInsets.only(left: 10, right: 10),
          margin: EdgeInsets.only(bottom: 10),
          child: Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                child: Image.network(
                  category.image,
                  width: screenSize.width,
                  fit: BoxFit.cover,
                  alignment: Alignment(
                      0.0, (offset >= -1 && offset <= 1) ? offset : (offset > 0) ? 1.0 : -1.0),
                ),
              ),
              Container(
                width: screenSize.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                child: Container(
                  width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
                  height: screenSize.width * 0.35,
                  child: Center(
                    child: Text(
                      category.name.toUpperCase(),
                      style:
                          TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubItem extends StatelessWidget {
  final Category category;
  final bool isLast;

  SubItem(this.category, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
          padding: EdgeInsets.symmetric(vertical: 5),
          margin: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kGrey200))),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: isLast ? 50 : 20,
              ),
              Expanded(child: Text(category.name)),
              InkWell(
                onTap: () {
                  Product.showList(context: context, cateId: category.id, cateName: category.name);
                },
                child: Text(
                  "${category.totalProduct} items",
                  style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
                ),
              ),
              IconButton(
                  icon: Icon(Icons.keyboard_arrow_right),
                  onPressed: () {
                    Product.showList(
                        context: context, cateId: category.id, cateName: category.name);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
