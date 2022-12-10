import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_detail/daily_detail_view_model.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class DailyPhotoView extends StatefulWidget {
  const DailyPhotoView({Key? key}) : super(key: key);

  @override
  DailyPhotoViewState createState() => DailyPhotoViewState();
}

class DailyPhotoViewState extends State<DailyPhotoView> {
  double verticalInset = 12;
  double horizontalInset = 16;
  late DailyDetailViewModel viewModel;
  late List<Image> imageList;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        viewModel = ref.watch(dailyDetailViewModelProvider);
        imageList = [];
        for (var photo in viewModel.selectedDaily.photoList) {
          ImageProvider image = Image.network(photo.imageUrl).image;
          imageList.add(Image(image: image, fit: BoxFit.cover));
        }

        if (imageList.isNotEmpty) {
          return Card(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  horizontalInset, verticalInset, horizontalInset, verticalInset / 2),
              child: Column(
                children: [
                  topRow(),
                  SizedBox(height: verticalInset),
                  photoGridView(context, imageList),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget topRow() {
    return Row(
      children: [
        Icon(
          KiiteIcons.image, color: Theme.of(context).primaryColor,
          // color: Theme.of(context).primaryColor.withOpacity(KiiteColors.iconOpacity),
        ),
        const SizedBox(width: 8),
        Text('シャシン', style: TextStyle(color: Theme.of(context).primaryColor)),
        Expanded(child: Container(width: double.infinity)),
      ],
    );
  }

  // シャシン選択＆追加ボタンタイルビュー
  Widget photoGridView(BuildContext context, List<Image> imageList) {
    int itemCount = imageList.length;
    int rowCount = ((itemCount) / 3).ceil();
    List<List<Image>> imageFileMatrix = [];

    for (var row = 0; row < rowCount; row++) {
      List<Image> imageRow = [];
      for (var column = 0; column < 3; column++) {
        // イメージの番号
        int index = row * 3 + column;

        if (index < imageList.length) {
          Image imageFile = imageList[index];
          imageRow.add(imageFile);
        } else {
          break;
        }
      }
      imageFileMatrix.add(imageRow);
    }

    return Column(children: [
      for (var row = 0; row < rowCount; row++) photoRow(context, imageFileMatrix[row]),
    ]);
  }

  // シャシン選択＆追加ボタンの列
  Widget photoRow(BuildContext context, List<Image> imageListInRow) {
    double marginBetween = 12;

    return Container(
      padding: EdgeInsets.only(bottom: marginBetween),
      child: Row(
        children: [
          for (var index = 0; index < 5; index++)
            if (index % 2 == 1)
              SizedBox(width: marginBetween)
            else if (index / 2 < imageListInRow.length)
              imageTile(context, (index / 2).round())
            else
              blankTile()
        ],
      ),
    );
  }

  // 選択済みシャシンタイル
  Widget imageTile(BuildContext context, int index) {
    // double buttonSize = 28;
    // double iconSize = 24;
    // double crossMarkSize = 14;
    final image = imageList[index];

    return Expanded(
      flex: 1,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          // border: Border.all(color: KiiteColors.grey, width: 0.2),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 0.5,
              offset: const Offset(0, 0.5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              AspectRatio(aspectRatio: 1, child: Image(image: image.image, fit: BoxFit.cover)),
              AspectRatio(
                aspectRatio: 1,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Container(),
                  onPressed: () {
                    _tapOnImage(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget blankTile() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.pink,
      ),
    );
  }

  void _tapOnImage(int index) {
    // final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          backgroundColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(0),
          insetPadding: const EdgeInsets.all(0),
          children: [
            _imageWidget(index),
          ],
        );
      },
    );
  }

  Widget _imageWidget(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      child: imageList[index],
      onTapUp: (event) {
        double positionFromCenter = event.globalPosition.dx - screenWidth / 2;
        if (screenWidth / 6 < positionFromCenter) {
          if (index < imageList.length - 1) {
            Navigator.of(context).pop();
            _tapOnImage(index + 1);
          } else {
            Navigator.of(context).pop();
          }
        } else if (positionFromCenter < -screenWidth / 6) {
          if (0 < index) {
            Navigator.of(context).pop();
            _tapOnImage(index - 1);
          } else {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      onHorizontalDragEnd: (gesture) {
        if (0 < gesture.velocity.pixelsPerSecond.dx) {
          if (0 < index) {
            Navigator.of(context).pop();
            _tapOnImage(index - 1);
          } else {
            Navigator.of(context).pop();
          }
        } else {
          if (index < imageList.length - 1) {
            Navigator.of(context).pop();
            _tapOnImage(index + 1);
          } else {
            Navigator.of(context).pop();
          }
        }
      },
    );
  }
}
