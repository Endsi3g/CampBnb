/// Widget pour sélectionner la langue de l'application
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final appLocalizations = AppLocalizations.of(context);
    final currentAppLocale = AppLocale.fromLocale(currentLocale);

    return ExpansionTile(
      leading: const Icon(Icons.language),
      title: Text(appLocalizations?.translate('language') ?? 'Language'),
      subtitle: Text(currentAppLocale?.nativeName ?? 'Français (Canada)'),
      children: [
        ...AppLocale.supportedLocales.map((appLocale) {
          final isSelected =
              currentLocale.languageCode == appLocale.languageCode &&
              currentLocale.countryCode == appLocale.countryCode;

          return ListTile(
            leading: Text(appLocale.flag, style: const TextStyle(fontSize: 24)),
            title: Text(appLocale.nativeName),
            subtitle: Text(appLocale.name),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(appLocale.locale);
              Navigator.of(context).pop();
            },
          );
        }),
      ],
    );
  }
}
