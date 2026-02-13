class CallArgsModel {
  final String? q;
  final String? page;

  CallArgsModel({this.q, this.page});

  factory CallArgsModel.fromJson(Map<String, dynamic> json) {
    return CallArgsModel(
      q: json['q'],
      page: json['page'],
    );
  }
}
