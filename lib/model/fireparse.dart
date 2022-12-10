class Fireparse {
  static List<String> stringListFromDynamicList(List<dynamic>? inputList) {
    List<String> output = [];
    if (inputList == null || inputList.isEmpty) {
      output = <String>[];
    } else {
      for (var element in inputList) {
        output.add(element.toString());
      }
    }
    return output;
  }

  static List<String> stringListFromSet(Set<dynamic>? inputList) {
    List<String> output = [];
    if (inputList == null || inputList.isEmpty) {
      output = <String>[];
    } else {
      for (var element in inputList) {
        output.add(element.toString());
      }
    }
    return output;
  }

  static Set<String> stringSetFromList(List<dynamic>? inputList) {
    Set<String> output = {};
    if (inputList == null || inputList.isEmpty) {
      output = <String>{};
    } else {
      for (var element in inputList) {
        output.add(element.toString());
      }
    }
    return output;
  }
}
