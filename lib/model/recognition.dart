import 'dart:convert';

List<RecognitionValue> recognitionValueFromJson(List<dynamic> recog) =>
    List<RecognitionValue>.from(
        recog.map((x) => RecognitionValue.fromJson(x)));

String recognitionValueToJson(List<RecognitionValue> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RecognitionValue {
  RecognitionValue({
    this.confidence,
    this.index,
    this.label,
  });

  double confidence;
  int index;
  String label;

  factory RecognitionValue.fromJson(Map<String, dynamic> json) =>
      RecognitionValue(
        confidence: json["confidence"].toDouble(),
        index: json["index"],
        label: json["label"],
      );

  Map<String, dynamic> toJson() => {
        "confidence": confidence,
        "index": index,
        "label": label,
      };
}

class Recognition {
  double obscene = -1;
  double nonObscene = -1;
  Recognition(List<RecognitionValue> recognitionValues) {
    for (RecognitionValue value in recognitionValues) {
      if (value.label == "obscene") {
        obscene = value.confidence;
      }
      if (value.label == "non-obscene") {
        nonObscene = value.confidence;
      }
    }
  }
  Map<String, dynamic> toJson() => {
        "obscene": obscene,
        "non-obscene": nonObscene,
      };

  @override
  String toString() {
    return 'Obscene:\n$obscene\nNon-obscene:\n$nonObscene';
  }
}
