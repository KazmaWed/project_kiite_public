// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final confirmTabCloseStreamProvider = StreamProvider.autoDispose<void>(
  (ref) => window.onBeforeUnload.map(
    (event) {
      final beforeUnloadEvent = event as BeforeUnloadEvent;
      beforeUnloadEvent.preventDefault();
      beforeUnloadEvent.returnValue = '';
    },
  ),
);

// final confirmTabCloseStreamProvider = StreamProvider.autoDispose<void>((ref) => Stream.value(null));
