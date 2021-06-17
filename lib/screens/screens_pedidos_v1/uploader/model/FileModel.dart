class FileModelThumbnail {
  String url;

  FileModelThumbnail({this.url = ''});

  factory FileModelThumbnail.fromJson(Map<String, dynamic> data) {
    return FileModelThumbnail(
      url: data['thumbnail']['url'] ?? '',
    );
  }
}

class FileModelFormat {
  String url;
  FileModelFormat({this.url = ''});

  factory FileModelFormat.fromJson(Map<String, dynamic> data) {
    return FileModelFormat(
      url: data['thumbnail']['url'] ?? '',
    );
  }
}

// ---------------------------------------------------------

class FileModel {
  int id;
  String name;
  String url;
  FileModelFormat? formats;

  FileModel({
    this.id = 0,
    this.name = '',
    this.url = '',
    this.formats,
  });

  factory FileModel.fromJson(Map<String, dynamic> data) {
    return FileModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      url: data['url'] ?? '',
      formats: FileModelFormat.fromJson(data['formats']) ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}
