import 'package:kiite/model/fireparse.dart';

class Reaction {
  Set<String> likedBy = {};
  Set<String> encouragedBy = {};
  Set<String> inspired = {};

  Map<String, List<String>> toMap() {
    return {
      'likedBy': likedBy.toList(),
      'encouragedBy': encouragedBy.toList(),
      'inspired': inspired.toList(),
    };
  }

  bool hasData() {
    return likedBy.isNotEmpty || encouragedBy.isNotEmpty || inspired.isNotEmpty;
  }

  bool hasNoData() {
    return likedBy.isEmpty && encouragedBy.isEmpty && inspired.isEmpty;
  }

  static Reaction fromMap(Map<String, List<String>> map) {
    final output = Reaction();
    output.likedBy = Fireparse.stringSetFromList(map['likedBy']);
    output.encouragedBy = Fireparse.stringSetFromList(map['encouragedBy']);
    output.inspired = Fireparse.stringSetFromList(map['inspired']);
    return output;
  }
}