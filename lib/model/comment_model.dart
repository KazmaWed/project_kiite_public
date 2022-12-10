import 'package:kiite/model/daily_model.dart';

class CommentTimeline {
  CommentTimeline({required this.dailyId});
  String dailyId;
  late String dailyAuthorId;
  late DateTime dailyDateTime;
  late DateTime commented;
  // List<Comment> commentList = [];

  void setMap(Map<String, dynamic> map) {
    dailyAuthorId = map['dailyAuthorId'];
    dailyDateTime = DateTime.fromMillisecondsSinceEpoch(map['dailyDateTime']);
    commented = DateTime.fromMillisecondsSinceEpoch(map['commented']);
  }
}

class Comment {
  Comment({required this.body, required this.posted, this.dailyAuthorId});

  String body;
  DateTime posted;
  String? id;
  String? authorId;
  String? dailyId;
  String? dailyAuthorId;
  DateTime? dailyDateTime;

  void setDaily(Daily daily) {
    dailyId = daily.id;
    dailyAuthorId = daily.authorId;
    dailyDateTime = daily.dateTime;
  }

  // -------------------- 変換メソッドなど --------------------

  Map<String, dynamic> toMapWithId() {
    Map<String, dynamic> map = toFireMap();
    map['id'] = id;
    return map;
  }

  Map<String, dynamic> toFireMap() {
    return {
      'authorId': authorId,
      'dailyAuthorId': dailyAuthorId,
      'dailyId': dailyId,
      'body': body,
      'posted': posted.millisecondsSinceEpoch,
    };
  }

  Map<String, dynamic> toTimelineMap() {
    Map<String, dynamic> map = {
      'authorId': authorId,
      'commented': DateTime.now().millisecondsSinceEpoch,
      'dailyAuthorId': dailyAuthorId,
      'dailyDateTime': dailyDateTime == null ? null : dailyDateTime!.millisecondsSinceEpoch,
    };
    return map;
  }

  static Comment fromMap(Map<String, dynamic> map) {
    Comment comment = Comment(
      body: map['body'],
      posted: DateTime.fromMillisecondsSinceEpoch(map['posted']),
    );
    comment.id = map['id'];
    comment.authorId = map['authorId'];
    comment.dailyId = map['dailyId'];
    comment.dailyAuthorId = map['dailyAuthorId'];
    return comment;
  }
}
