class RoleModel {
  int id;
  String name;

  RoleModel({this.id = 0, this.name = ''});

  factory RoleModel.fromJson(Map<String, dynamic> data) {
    return RoleModel(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
