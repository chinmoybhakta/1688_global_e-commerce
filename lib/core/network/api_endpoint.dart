class ApiEndpoints {
  static const String baseUrl = "https://api-gw.onebound.cn/1688";
  static const String key = "t_8801910700445";
  static const String secret = "POSWORD";

  static const String getItem = "item_get/?key=$key&num_iid=945346115616&lang=en&secret=$secret";
  static const String serachItems = "item_search/?key=$key&q=bag&start_price=0&end_price=0&page=2&cat=0&lang=en&secret=$secret";
}