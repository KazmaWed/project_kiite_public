import 'package:intl/intl.dart';
import 'package:kiite/model/fireparse.dart';

class Daily {
  Daily({required this.authorId, required this.posted, required this.dateTime});

  String? id;
  String? authorId;
  DateTime dateTime;
  DateTime posted;
  List<Effort> effortList = [];
  String body = '';
  List<Photo> photoList = [];

  static String defaultBody = '# キーテ！\n\n\n# デモネ...\n\n\n# アシタ？\n';

  // -------------------- 変換メソッドなど --------------------

  Map<String, dynamic> toMapWithId() {
    final map = toFireMap();
    map['id'] = id;
    return map;
  }

  Map<String, dynamic> toFireMap() {
    List<String> effortTitleList = [];
    List<String> lengthList = [];
    List<String> imageUrlList = [];
    List<String> imagePathList = [];

    for (var element in effortList) {
      effortTitleList.add(element.title);
      lengthList.add(element.length);
    }
    for (var element in photoList) {
      imageUrlList.add(element.imageUrl);
      imagePathList.add(element.imagePath);
    }

    return {
      'authorId': authorId,
      'posted': posted.millisecondsSinceEpoch,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'titleList': effortTitleList,
      'lengthList': lengthList,
      'body': body,
      'imageUrlList': imageUrlList,
      'imagePathList': imagePathList,
    };
  }

  static Daily fromMap(Map<String, dynamic> map) {
    // id
    String? id = map['id'];

    // 投稿者id
    String? authorId = map['authorId'];

    // 登校日
    int postedInt = map['posted'];
    int dateTimeInt = map['dateTime'];
    DateTime posted = DateTime.fromMillisecondsSinceEpoch(postedInt);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateTimeInt);

    // 本文
    String body = map['body'];

    // 画像URLリスト
    List<Photo> photoList = [];
    List<String> imageUrlList = Fireparse.stringListFromDynamicList(map['imageUrlList']);
    List<String> imagePathList = Fireparse.stringListFromDynamicList(map['imagePathList']);
    for (var index = 0; index < imageUrlList.length; index++) {
      Photo newPhoto = Photo(imageUrl: imageUrlList[index], imagePath: imagePathList[index]);
      photoList.add(newPhoto);
    }

    // 作業時間リスト
    List<Effort> effortList = [];
    List<String> effortTitleList = Fireparse.stringListFromDynamicList(map['titleList']);
    List<String> lengthList = Fireparse.stringListFromDynamicList(map['lengthList']);
    for (var idx = 0; idx < effortTitleList.length; idx++) {
      effortList.add(Effort(
        title: effortTitleList[idx],
        length: lengthList[idx],
      ));
    }

    // 出力用Daily作成
    Daily output = Daily(
      authorId: authorId,
      posted: posted,
      dateTime: dateTime,
    );
    output.id = id;
    output.body = body;
    output.effortList = effortList;
    // output.imageUrlList = imageUrlList;
    output.photoList = photoList;
    return output;
  }

  double totalLength() {
    double output = 0;
    for (var element in effortList) {
      output += double.parse(element.length);
    }
    return output;
  }

  bool isBlank() {
    // ホンブン空白確認
    bool bodyIsBlank = body.replaceAll('\n', '') == defaultBody.replaceAll('\n', '') ||
        body.replaceAll('\n', '') == '';
    // ジカン空白確認
    bool effortIsBlank = true;
    for (int index = 0; index < effortList.length; index++) {
      if (effortList[index].title.replaceAll(' ', '').replaceAll('　', '') != '') {
        effortIsBlank = false;
        break;
      }
    }
    return bodyIsBlank && effortIsBlank;
  }

  @override
  String toString() {
    return {
      'id': id,
      'autherId': authorId,
      'posted': DateFormat('MM/dd E.').format(posted),
      'dateTime': DateFormat('MM/dd E.').format(dateTime),
      'effortList': '${effortList.length} items',
    }.toString();
  }
}

class Effort {
  Effort({required this.title, required this.length});

  String title;
  String length;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'length': length,
    };
  }

  @override
  String toString() {
    return {'title': title, 'length': length}.toString();
  }
}

class Photo {
  Photo(
      {this.id,
      required this.imageUrl,
      required this.imagePath,
      // required this.sumbnailUrl,
      // required this.sumbnailPath,
      this.createdAt});

  final String? id;
  final String imageUrl;
  final String imagePath;

  // final String sumbnailUrl;
  // final String sumbnailPath;
  final DateTime? createdAt;

  @override
  String toString() {
    return {'id': id, 'imageURL': imageUrl, 'imagePath': imagePath, 'createdAt': createdAt}
        .toString();
  }
}
