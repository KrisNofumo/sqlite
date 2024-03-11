final String table = 'my_table';

class ModelDataBase {
  static final List<String> values = [id, name, age];

  static final String id = 'id';
  static final String age = 'age';
  static final String name = 'name';
}

class Model {
  final int? id;
  final int age;
  final String name;

  const Model({
    this.id,
    required this.age,
    required this.name,
  });

  Model copy({
    int? id,
    int? age,
    String? name,
  }) =>
      Model(
        id: id ?? this.id,
        age: age ?? this.age,
        name: name ?? this.name,
      );

  static Model fromJson(Map<String, Object?> json) => Model(
        id: json[ModelDataBase.id] as int?,
        age: json[ModelDataBase.age] as int,
        name: json[ModelDataBase.name] as String,
      );

  Map<String, Object?> toJson() => {
        ModelDataBase.id: id,
        ModelDataBase.age: age,
        ModelDataBase.name: name,
      };
}
