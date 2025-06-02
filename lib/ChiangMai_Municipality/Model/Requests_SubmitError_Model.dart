
class SubmitErrorResponse {
  final String message;
  final Errors errors;

  SubmitErrorResponse({required this.message, required this.errors});

  factory SubmitErrorResponse.fromJson(Map<String, dynamic> json) {
    return SubmitErrorResponse(
      message: json['message'],
      errors: Errors.fromJson(json['errors']),
    );
  }
}

class Errors {
  final List<String> attachments;
  final List<MissingDoc> missingDocs;

  Errors({required this.attachments, required this.missingDocs});

  factory Errors.fromJson(Map<String, dynamic> json) {
    return Errors(
      attachments: List<String>.from(json['attachments'] ?? []),
      missingDocs: (json['missing_docs'] as List)
          .map((e) => MissingDoc.fromJson(e))
          .toList(),
    );
  }
}

class MissingDoc {
  final int id;
  final String code;
  final String nameTh;

  MissingDoc({required this.id, required this.code, required this.nameTh});

  factory MissingDoc.fromJson(Map<String, dynamic> json) {
    return MissingDoc(
      id: json['id'],
      code: json['code'],
      nameTh: json['name_th'],
    );
  }
}
