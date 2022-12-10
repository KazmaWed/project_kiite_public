class TransportFee {
  String? id = '';
  String userId = '';
  late DateTime posted;
  late DateTime used;
  String fromTitle = '';
  String toTitle = '';
  String fromStation = '';
  String toStation = '';
  int price = 0;

  Map<String, dynamic> toFullMap() {
    return {
      'id': id,
      'userId': userId,
      'posted': posted.millisecondsSinceEpoch,
      'used': used.millisecondsSinceEpoch,
      'fromTitle': fromTitle,
      'toTitle': toTitle,
      'fromStation': fromStation,
      'toStation': toStation,
      'price': price,
    };
  }

  Map<String, dynamic> toFireMap() {
    return {
      'userId': userId,
      'posted': posted.millisecondsSinceEpoch,
      'used': used.millisecondsSinceEpoch,
      'fromTitle': fromTitle,
      'toTitle': toTitle,
      'fromStation': fromStation,
      'toStation': toStation,
      'price': price,
    };
  }

  static TransportFee fromMap(Map<String, dynamic> map) {
    final output = TransportFee();
    output.id = map['id'];
    output.userId = map['userId'];
    output.posted = DateTime.fromMillisecondsSinceEpoch(map['posted']);
    output.used = DateTime.fromMillisecondsSinceEpoch(map['used']);
    output.fromTitle = map['fromTitle'];
    output.toTitle = map['toTitle'];
    output.fromStation = map['fromStation'];
    output.toStation = map['toStation'];
    output.price = map['price'];
    return output;
  }
}