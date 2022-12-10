import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiite/model/kiite_colors.dart';
import 'package:kiite/model/project_model.dart';

class ProjectRepository {
  bool networking = false;

  // ---------- プロジェクト保存 ----------
  Future<bool> addProject(Project project) async {
    bool succeed = true;

    // プロジェクトタイトル保存
    final projectTitle = {'title': project.title};
    final task =
        await FirebaseFirestore.instance.collection('project').add(projectTitle).catchError((e) {
      succeed = false;
    });

    // 他の読み方保存
    final List<Future<dynamic>> future = [];
    for (var element in project.otherForm) {
      if (element.isNotEmpty) {
        future.add(
          FirebaseFirestore.instance
              .collection('project/${task.id}/otherForm')
              .add({'data': element}).catchError((error) {
            succeed = false;
          }),
        );
      }
    }
    // 全ての処理を待って終了
    await Future.wait(future);
    return succeed;
  }

  // ---------- プロジェクト情報更新 ----------
  Future<bool> updateProject(Project project) async {
    bool succeed = true;

    // プロジェクトタイトル更新
    final projectTitle = {'title': project.title};
    List<Future<dynamic>> future = [];
    await FirebaseFirestore.instance
        .doc('project/${project.id}')
        .update(projectTitle)
        .whenComplete(() async {
      await FirebaseFirestore.instance
          .collection('project/${project.id}/otherForm')
          .get()
          .then((value) {
        for (var doc in value.docs) {
          future.add(FirebaseFirestore.instance.doc(doc.reference.path).delete());
        }
      }).catchError((e) {
        succeed = false;
      });
    }).catchError((e) {
      succeed = false;
    });

    // 他の読み方更新
    await Future.wait(future);
    future = [];

    for (var element in project.otherForm) {
      if (element.isNotEmpty) {
        final data = {'data': element};
        future.add(
          FirebaseFirestore.instance
              .collection('project/${project.id}/otherForm')
              .add(data)
              .catchError((error) {
            succeed = false;
          }),
        );
      }
    }
    // 全ての処理を待って終了
    await Future.wait(future);
    return succeed;
  }

  // プロジェクト削除
  Future<bool> removeProject(Project project) async {
    bool succeed = true;
    List<Future<dynamic>> future = [];
    await FirebaseFirestore.instance
        .collection('project/${project.id}/otherForm')
        .get()
        .then((value) {
      for (var doc in value.docs) {
        future.add(
          FirebaseFirestore.instance
              .doc('project/${project.id}/otherForm/${doc.id}')
              .delete()
              .catchError((e) => {succeed = false}),
        );
      }
    });

    await Future.wait(future);

    await FirebaseFirestore.instance.doc('project/${project.id}').delete().catchError((e) {
      succeed = false;
    });
    return succeed;
  }

  // プロジェクトをIDで取得
  Future<Project> getProjectById(String projectId) async {
    late Project project;

    // タイトル取得
    await FirebaseFirestore.instance.doc('project/$projectId').get().then((doc) async {
      final Map<String, dynamic> map = doc.data()!;
      project = Project(title: map['title'], otherForm: {});
      project.id = doc.id;

      // 他の読み方取得
      await FirebaseFirestore.instance
          .collection('project/$projectId/otherForm')
          .get()
          .then((value) async {
        List<String> list = [];
        for (var doc in value.docs) {
          list.add(doc['data']);
        }
        list.sort((a, b) => a.compareTo(b));
        project.otherForm = list.toSet();
      });
    });

    return project;
  }

  // プロジェクトをIDで取得
  Future<Set<String>> getOtherFormById(String projectId) async {
    Set<String> otherForm = {};

    // タイトル取得
    await FirebaseFirestore.instance
        .collection('project/$projectId/otherForm')
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        otherForm.add(doc['data']);
      }
    });

    return Future.value(otherForm);
  }

  // 全てのプロジェクト取得
  Future<List<Project>> allProject() async {
    final output = <Project>[];
    List<Future<dynamic>> future = [];

    // プロジェクトを取得
    await FirebaseFirestore.instance.collection('project').get().then((projectCollection) {
      for (var eachProject in projectCollection.docs) {
        final newProject = Project(title: eachProject.data()['title'], otherForm: {});
        newProject.id = eachProject.id;
        output.add(newProject);

        future.add(
          FirebaseFirestore.instance
              .collection('project/${newProject.id}/otherForm')
              .get()
              .then((value) {
            List<String> list = [];
            for (var doc in value.docs) {
              list.add(doc['data']);
            }
            list.sort((a, b) => a.compareTo(b));
            newProject.otherForm = list.toSet();
          }),
        );
      }
    });

    await Future.wait(future);
    output.sort((a, b) => a.title.compareTo(b.title));
    return output;
  }

  // 全てのプロジェクトを先頭一致、部分一致でフィルター
  Future<List<Project>> getSuggestion(String pattern) async {
    final rawData = await allProject();
    rawData.sort((a, b) => a.title.compareTo(b.title));
    final prefixMatch = <Project>[];
    final contains = <Project>[];
    final others = <Project>[];

    // ひらがな＆小文字化
    String patternInHira = pattern.hiragana.toLowerCase();

    // 全件先頭一致確認
    for (var project in rawData) {
      bool matched = false;
      // タイトル先頭一致確認
      String titleInHira = project.title.hiragana.toLowerCase();
      if (titleInHira.startsWith(patternInHira)) {
        prefixMatch.add(project);
        matched = true;
      } else {
        // 読み方先頭一致確認
        for (var otherForm in project.otherForm) {
          String otherFormInHira = otherForm.hiragana.toLowerCase();
          if (otherFormInHira.startsWith(patternInHira)) {
            prefixMatch.add(project);
            matched = true;
            break;
          }
        }
      }
      // 見つからなければ
      if (!matched) {
        others.add(project);
      }
    }

    // 先頭一致しなかった物の部分一致確認
    for (var project in others) {
      // タイトルの部分一致確認
      String titleInHira = project.title.hiragana.toLowerCase();
      if (titleInHira.contains(patternInHira)) {
        contains.add(project);
      } else {
        for (var otherForm in project.otherForm) {
          String otherFormInHira = otherForm.hiragana.toLowerCase();
          if (otherFormInHira.contains(patternInHira)) {
            prefixMatch.add(project);
            break;
          }
        }
      }
    }

    return [...prefixMatch, ...contains];
  }
}
