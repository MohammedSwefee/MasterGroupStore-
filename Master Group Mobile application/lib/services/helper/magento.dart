class MagentoHelper {
  static String getCustomAttribute(customAttributes, attribute) {
    String value;
    if (customAttributes != null && customAttributes.length > 0) {
      for (var item in customAttributes) {
        if (item["attribute_code"] == attribute) {
          value = item["value"];
          break;
        }
      }
    }
    return value;
  }

  static String getProductImageUrlByName(domain, imageName) {
    return "$domain/pub/media/catalog/product/$imageName";
  }

  static String getProductImageUrl(domain, item, [attribute = "thumbnail"]) {
    final imageName = getCustomAttribute(item["custom_attributes"], attribute);
    if (imageName != null) {
      return imageName.contains("http")
          ? imageName
          : getProductImageUrlByName(domain, imageName);
    } else {
      return "";
    }
  }

  static String getCategoryImageUrl(domain, item, [attribute = "image"]) {
    final imageName = getCustomAttribute(item["custom_attributes"], attribute);
    if (imageName != null) {
      return "$domain/pub/media/catalog/category/$imageName";
    }
    return "";
  }
}
