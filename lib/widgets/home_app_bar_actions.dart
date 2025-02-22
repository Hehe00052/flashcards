import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../translations/app_localizations.dart';

class HomeAppBarActions extends StatelessWidget {
  final bool isSmallScreen;
  final bool showExtraText;
  final VoidCallback onImportFlashcards;
  final VoidCallback onToggleExtraText;
  final VoidCallback onShuffleFlashcards;
  final VoidCallback onShowRandomFlashcard;

  const HomeAppBarActions({
    super.key,
    required this.isSmallScreen,
    required this.showExtraText,
    required this.onImportFlashcards,
    required this.onToggleExtraText,
    required this.onShuffleFlashcards,
    required this.onShowRandomFlashcard,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    if (isSmallScreen) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              Provider.of<SettingsProvider>(context, listen: false).toggleTheme();
            },
            tooltip: appLocalizations.get('toggleTheme'),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            Provider.of<SettingsProvider>(context, listen: false).toggleTheme();
          },
          tooltip: appLocalizations.get('toggleTheme'),
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            Provider.of<SettingsProvider>(context, listen: false).toggleLanguage();
          },
          tooltip: appLocalizations.get('toggleLanguage'),
        ),
        IconButton(
          icon: const Icon(Icons.file_upload),
          onPressed: onImportFlashcards,
          tooltip: appLocalizations.get('importFromFile'),
        ),
        IconButton(
          icon: Icon(showExtraText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleExtraText,
          tooltip: showExtraText
              ? appLocalizations.get('hideExtraText')
              : appLocalizations.get('showExtraText'),
        ),
        IconButton(
          icon: const Icon(Icons.shuffle),
          onPressed: onShuffleFlashcards,
          tooltip: appLocalizations.get('shuffleCards'),
        ),
        IconButton(
          icon: const Icon(Icons.casino),
          onPressed: onShowRandomFlashcard,
          tooltip: appLocalizations.get('randomCard'),
        ),
      ],
    );
  }
}