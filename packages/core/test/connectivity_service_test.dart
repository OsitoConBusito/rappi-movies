import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

class _MockChecker extends Mock implements InternetConnection {}

void main() {
  group('ConnectivityService', () {
    test('given connected, then statusStream emits online', () {
      final checker = _MockChecker();
      when(
        () => checker.onStatusChange,
      ).thenAnswer((_) => Stream.value(InternetStatus.connected));

      final service = ConnectivityService(checker: checker);

      expect(service.statusStream, emits(ConnectionStatus.online));
    });

    test('given disconnected, then statusStream emits offline', () {
      final checker = _MockChecker();
      when(
        () => checker.onStatusChange,
      ).thenAnswer((_) => Stream.value(InternetStatus.disconnected));

      final service = ConnectivityService(checker: checker);

      expect(service.statusStream, emits(ConnectionStatus.offline));
    });
  });
}
