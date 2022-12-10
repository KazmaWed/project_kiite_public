import 'package:flutter/material.dart';
import 'package:kiite/model/kiite_icons.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// プレビューの本体Widget
class LinkPreviewCard extends StatelessWidget {
  const LinkPreviewCard({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    final futureResponse = http.get(Uri.parse(url));
    // metaデータ取得状況で分岐するFutureBuilder
    return FutureBuilder(
      future: futureResponse,
      builder: (context, AsyncSnapshot<http.Response?> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // metaデータ取得中
          return const PreviewLoading();
        } else if (snapshot.hasError) {
          // データ取得でエラー
          return PreviewInvalid(url: url, error: snapshot.error.toString());
        } else if (!snapshot.hasData) {
          // データがない
          return PreviewInvalid(url: url);
        } else {
          // metaデータ取得できた場合
          var document = MetadataFetch.responseToDocument(snapshot.data!);
          var data = MetadataParser.parse(document);
          final title = data.title;
          final description = data.description;
          final imageUrl = data.image;
          // LinkPreviewTypeで分岐
          return PreviewBody(url: url, title: title, description: description, imageUrl: imageUrl);
        }
      },
    );
  }
}

// LinkPreviewType.basicの時の表示、中サイズ画像
class PreviewBody extends StatelessWidget {
  const PreviewBody({Key? key, required this.url, this.title, this.description, this.imageUrl})
      : super(key: key);
  final String url;
  final String? title;
  final String? description;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).textTheme.titleSmall!.color!.withOpacity(0.8),
        );
    final descriptionStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.8),
        );

    var titleFixed = title;
    if (title == '' || title == null) {
      titleFixed = url;
    }
    return Card(
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 96,
                    width: 96,
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(42),
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  ),
                ),
              if (imageUrl != null) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleFixed!,
                      style: titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description ?? 'No desctiption',
                      style: descriptionStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewLoading extends StatelessWidget {
  const PreviewLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(48),
        );
    final descriptionStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(48),
        );

    const titleText = 'タイトル';
    const descriptionText = 'ディスクリプション';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 96,
                width: 96,
                color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(42),
                child: Icon(
                  KiiteIcons.nature,
                  color: Theme.of(context).cardColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleText,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descriptionText,
                    style: descriptionStyle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewInvalid extends StatelessWidget {
  const PreviewInvalid({Key? key, required this.url, this.error}) : super(key: key);
  final String url;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Theme.of(context).textTheme.titleSmall!.color!.withOpacity(0.8),
        );
    final descriptionStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.6),
        );

    final titleText = url;
    final descriptionText = error ?? 'No description.';

    return Card(
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  // alignment: Alignment.center,
                  height: 96,
                  width: 96,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(42),
                  child: Icon(
                    KiiteIcons.nature,
                    size: 24,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: titleStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descriptionText,
                      style: descriptionStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<String> getLinkList(String text) {
  RegExp exp = RegExp(r'https?:\/\/[\w/\-?=%.]+\.[\w/\-?=%.]+');
  Iterable<RegExpMatch> matcheList = exp.allMatches(text);
  List<String> output = [];

  for (var match in matcheList) {
    output.add(text.substring(match.start, match.end));
  }
  return output;
}
