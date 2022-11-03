import 'package:cloud_firestore/cloud_firestore.dart';

class Pose{
  late String id;
  late String name;
  late String reps;

  Pose({
    required this.id,
    required this.name,
    required this.reps,
  });

  Map<String, dynamic> toJson() => {
    // 'id': id,
    'name': name,
    'reps': reps,
  };

  static Pose fromJson(Map<String, dynamic> json) => Pose(
    id: json['id'],
    name: json['name'],
    reps: json['reps'],
  );
}