class Coupons {
  var coupons = [];
  Coupons.getListCoupons(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromJson(i));
      //print(i.toString());
    }
    //print("hallo ${coupons.length}");
  }
}

class Coupon {
  double amount;
  var code;
  var message;
  var id;
  var discountType;

  Coupon.fromJson(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["amount"]);
      code = json["code"];
      id = json["id"];
      discountType = json["discount_type"];
      message = "Hello";
    } catch (e) {
      print(e.toString());
    }
  }
}
