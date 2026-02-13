class LanguageModel {
  final String? currentLang;
  final String? sourceLang;

  LanguageModel({this.currentLang, this.sourceLang});

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      currentLang: json['current_lang'],
      sourceLang: json['source_lang'],
    );
  }
}
