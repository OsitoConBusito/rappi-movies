import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'given es by default, when setLocale(en), then state updates and persists',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeControllerProvider), AppLocale.es);

      await container
          .read(localeControllerProvider.notifier)
          .setLocale(AppLocale.en);

      expect(container.read(localeControllerProvider), AppLocale.en);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    },
  );
}
