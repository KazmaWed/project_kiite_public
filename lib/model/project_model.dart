import 'package:kiite/model/fireparse.dart';

class Project {
  Project({required this.title, required this.otherForm});

  String? id;
  String title;
  Set<String> otherForm;

  Map<String, dynamic> toFireMap() {
    return {
      'title': title,
      'otherForm': otherForm.where((element) => element != '').toList(),
    };
  }

  Map<String, dynamic> toMapWithId() {
    return {
      'id': id,
      'title': title,
      'otherForm': otherForm.toList(),
    };
  }

  static Project fromMap(Map<String, dynamic> map) {
    final output = Project(
      title: map['title'],
      otherForm: Fireparse.stringSetFromList(map['otherForm']),
    );
    output.id = map['id'];
    return output;
  }

  @override
  String toString() {
    return {'title': title, 'otherFormLength': otherForm.length, 'id': id}.toString();
  }
}
