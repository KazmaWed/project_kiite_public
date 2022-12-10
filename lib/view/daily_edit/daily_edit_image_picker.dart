import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:kiite/view/daily_edit/daily_edit_view_model.dart';

class ImagePickerView extends StatefulWidget {
  const ImagePickerView({Key? key}) : super(key: key);

  @override
  ImagePickerViewState createState() => ImagePickerViewState();
}

class ImagePickerViewState extends State<ImagePickerView> {
  late DailyEditViewModel viewModel;

  bool imagePickRunning = false;

  @override
  Widget build(BuildContext context) {
    double horizontalInset = 16;
    double topInset = 16;
    double bottomInstet = 8;

    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        viewModel = ref.watch(dailyEditViewModelProvider);

        return Card(
          child: Container(
            padding: EdgeInsets.fromLTRB(horizontalInset, topInset, horizontalInset, bottomInstet),
            child: Column(children: [
              firstRow(context),
              const SizedBox(height: 16),
              photoGridView(context, viewModel.imageList),
            ]),
          ),
        );
      },
    );
  }

  // シャシンラベル
  Widget firstRow(BuildContext context) {
    return Row(children: [
      Icon(KiiteIcons.image, color: Theme.of(context).primaryColor),
      const SizedBox(width: 8),
      Text('シャシン', style: TextStyle(color: Theme.of(context).primaryColor)),
    ]);
  }

  // シャシン選択＆追加ボタンタイルビュー
  Widget photoGridView(BuildContext context, List<Image> imageList) {
    int itemCount = imageList.length;
    int rowCount = ((itemCount + 1) / 3).ceil();
    List<List<Image>> imageMatrix = [];

    for (var row = 0; row < rowCount; row++) {
      List<Image> imageRow = [];
      for (var column = 0; column < 3; column++) {
        // イメージの番号
        int index = row * 3 + column;
        if (index < imageList.length) {
          imageRow.add(imageList[index]);
        } else {
          break;
        }
      }
      imageMatrix.add(imageRow);
    }

    return Column(
      children: <Widget>[
        for (var row = 0; row < rowCount; row++) photoRow(context, imageMatrix[row])
      ],
    );
  }

  // シャシン選択＆追加ボタンの列
  Widget photoRow(BuildContext context, List<Image> imageList) {
    double marginBetween = 12;

    return Container(
      padding: EdgeInsets.only(bottom: marginBetween),
      child: Row(children: [
        for (var index = 0; index < 5; index++)
          if (index % 2 == 1)
            SizedBox(width: marginBetween)
          else if (index / 2 < imageList.length)
            imageTile(context, imageList[(index / 2).round()], (index / 2).round())
          else if (index / 2 == imageList.length)
            addPhotoTile(context)
          else
            blankTile(),
      ]),
    );
  }

  // 選択済みシャシンタイル
  Widget imageTile(BuildContext context, Image image, int index) {
    double buttonSize = 28;
    double iconSize = 24;
    double crossMarkSize = 14;

    return Expanded(
      flex: 1,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  child: Image(image: image.image, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: Icon(KiiteIcons.circle, color: Colors.white, size: iconSize),
            ),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child:
                  Icon(KiiteIcons.clear, color: Colors.black.withOpacity(0.6), size: crossMarkSize),
            ),
            SizedBox(
              width: buttonSize,
              height: buttonSize,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  primary: Colors.transparent,
                  shape: const CircleBorder(),
                ),
                onPressed: () => {_onRemove(index)},
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // シャシン削除ボタン
  void _onRemove(int index) {
    _unFocus();
    viewModel.removeImageAt(index);
    setState(() {});
  }

  // シャシン追加ボタン
  Widget addPhotoTile(BuildContext context) {
    return Expanded(
      flex: 1,
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5))),
            child:
                Icon(KiiteIcons.addImage, color: Theme.of(context).primaryColor.withOpacity(0.5)),
          ),
          onTap: () async {
            await _onAddButtonTap();
          },
        ),
      ),
    );
  }

  // 余白
  Widget blankTile() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.pink,
      ),
    );
  }

  // 追加ボタン
  Future<void> _onAddButtonTap() async {
    _unFocus();

    // 処理の重複防止
    if (!imagePickRunning) {
      //連続処理ガード
      imagePickRunning = true;

      // 画像選択
      ImagePicker().pickMultiImage().then((value) {
        setState(() => {viewModel.addXFileList(value)});
      });
      // 処理終了
      imagePickRunning = false;
    }
  }

  void _unFocus() {
    for (var focus in viewModel.focusList) {
      if (focus.hasFocus) {
        focus.unfocus();
        break;
      }
    }
  }
}
