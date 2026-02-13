class ApiEndpoints {
  static const String baseUrl = "https://1688-global-backend.vercel.app/";

  static String getItem(String numiid) => "item?numiid=$numiid";
  static String serachItems(String query, int page) => "search?q=$query&page=$page";
}