class Entity {

  final int? id;
  final String? name;

  Entity({required this.id, this.name});

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      name: json['name'],

    );
  }

  @override
  String toString() => name!;



}