class Announcement {
  Announcement({
    this.id,
    required this.title,
    required this.body,
    required this.created,
    required this.deliverDate,
    required this.dueDate,
    // required this.closeDate,
    required this.reactionTitle,
    this.reactedBy,
  });

  String? id;
  String title;
  String body;
  DateTime created;
  DateTime deliverDate;
  DateTime dueDate;
  // DateTime closeDate;
  String reactionTitle;
  List<String>? reactedBy = [];

  Map<String, dynamic> toFireMap() {
    Map<String, dynamic> output = {};

    output = {
      'title': title,
      'body': body,
      'created': created.millisecondsSinceEpoch,
      'deliverDate': deliverDate.millisecondsSinceEpoch,
      'dueDate': dueDate.millisecondsSinceEpoch,
      // 'closeDate': closeDate.millisecondsSinceEpoch,
      'reactionTitle': reactionTitle,
      // 'reactedBy': reactedBy,
    };
    return output;
  }

  static Announcement fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: null,
      title: map['title'],
      body: map['body'],
      created: DateTime.fromMillisecondsSinceEpoch(map['created']),
      deliverDate: DateTime.fromMillisecondsSinceEpoch(map['deliverDate']),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      // closeDate: DateTime.fromMillisecondsSinceEpoch(map['closeDate']),
      reactedBy: map['reactedBy'] ?? [],
      reactionTitle: map['reactionTitle'],
    );
  }

  static Announcement newItem() {
    return Announcement(
      id: null,
      title: '',
      body: '',
      created: DateTime.now(),
      deliverDate: DateTime.now(),
      dueDate: DateTime.now(),
      reactionTitle: '対応しました',
      reactedBy: [],
    );
  }
}
