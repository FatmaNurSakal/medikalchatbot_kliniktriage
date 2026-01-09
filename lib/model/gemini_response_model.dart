class GeminiResponseModel {
  List<Candidates>? candidates;

  GeminiResponseModel({this.candidates});

  GeminiResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['candidates'] != null) {
      candidates = <Candidates>[];
      json['candidates'].forEach((v) {
        candidates!.add(Candidates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (candidates != null) {
      data['candidates'] = candidates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Candidates {
  Content? content;
  String? finishReason;

  Candidates({this.content, this.finishReason});

  Candidates.fromJson(Map<String, dynamic> json) {
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;
    finishReason = json['finishReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['finishReason'] = finishReason;
    return data;
  }
}

class Content {
  List<Parts>? parts;

  Content({this.parts});

  Content.fromJson(Map<String, dynamic> json) {
    if (json['parts'] != null) {
      parts = <Parts>[];
      json['parts'].forEach((v) {
        parts!.add(Parts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (parts != null) {
      data['parts'] = parts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Parts {
  String? text;

  Parts({this.text});

  Parts.fromJson(Map<String, dynamic> json) {
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    return data;
  }
}
