import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nuni/core/supabase/change_signal.dart';

void main() {
  group('ChangeSignal', () {
    late List<StreamController<Object?>> opened;
    late int changes;
    late ChangeSignal signal;

    setUp(() {
      opened = [];
      changes = 0;
      signal = ChangeSignal(
        () {
          final controller = StreamController<Object?>();
          opened.add(controller);
          return controller.stream;
        },
        () => changes++,
        retryDelay: const Duration(milliseconds: 10),
      );
    });

    tearDown(() => signal.cancel());

    test('forwards every event as a change', () async {
      opened.single
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      expect(changes, 2);
    });

    test('re-opens after an error, once, and asks for a refresh', () async {
      opened.single
        ..addError(Exception('channel error'))
        ..addError(Exception('again'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(opened, hasLength(2));
      expect(changes, 1);

      opened.last.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(changes, 2);
    });

    test('re-opens after the stream closes', () async {
      await opened.single.close();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(opened, hasLength(2));
    });

    test('stays closed once cancelled', () async {
      opened.single.addError(Exception('channel error'));
      await signal.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(opened, hasLength(1));
      expect(changes, 0);
    });
  });
}
