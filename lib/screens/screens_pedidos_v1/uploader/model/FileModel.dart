class FileModelSizes {
  String thumbnail;

  FileModelSizes({this.thumbnail = ''});

  factory FileModelSizes.fromJson(Map<String, dynamic> data) {
    return FileModelSizes(
      thumbnail: data['url'] ?? '',
    );
  }
}

// ------------------------------------------------------------------
class FileModelFormats {
  FileModelSizes? thumbnail;

  FileModelFormats({this.thumbnail});

  factory FileModelFormats.fromJson(Map<String, dynamic> data) {
    return FileModelFormats(
      thumbnail: data['thumbnail']['url'] ?? '',
    );
  }
}

// ------------------------------------------------------------------

class FileModel {
  int id;
  String name;
  String url;
  FileModelFormats? formats;

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
      formats: FileModelFormats.fromJson(data['formats']),
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
