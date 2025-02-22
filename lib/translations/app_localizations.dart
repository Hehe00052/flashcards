import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'flashcards': 'Flashcards',
      'addFlashcard': 'Add Flashcard',
      'editFlashcard': 'Edit Flashcard',
      'front': 'Front',
      'back': 'Back',
      'add': 'Add',
      'save': 'Save',
      'cancel': 'Cancel',
      'noFlashcards': 'No flashcards yet',
      'importFromFile': 'Import from file',
      'hideExtraText': 'Hide extra text',
      'showExtraText': 'Show extra text',
      'shuffleCards': 'Shuffle cards',
      'randomCard': 'Random card',
      'loading': 'Loading...',
      'noValidData': 'No valid data found in file.',
      'foundFlashcards': 'Found {count} flashcards',
      'previewFirst5': 'Preview first 5 cards:',
      'importData': 'Import data',
      'addedNewFlashcards': 'Added {count} new flashcards',
      'errorImportingFile': 'Error importing file: {error}',
      'toggleTheme': 'Toggle light/dark mode',
      'toggleLanguage': 'Switch language',
      'randomCardSelected': 'Tada, random card selected here :3',

      'close': 'Close',
      'viewFront': 'View front',
      'viewBack': 'View back',
    
      'errorLoadingFile': 'Error loading file: {error}',
      'errorSavingFile': 'Error saving file: {error}',
      'selectingRandom': 'hold on, selecting random here :3',
    },
    'vi': {
      'errorLoadingFile': 'Lỗi khi đọc file: {error}',
      'errorSavingFile': 'Lỗi khi ghi file: {error}',
      'errorImportingFile': 'Lỗi khi nhập file: {error}',
      'addFlashcard': 'Thêm Flashcard',
      'editFlashcard': 'Chỉnh sửa Flashcard',
      'front': 'Mặt trước',
      'back': 'Mặt sau',
      'add': 'Thêm',
      'save': 'Lưu',
      'randomCardSelected': 'Tada, random trúng kái lày gòi nè :3',
      'hideExtraText': 'Ẩn phần text phụ',
      'showExtraText': 'Hiện phần text phụ',
      'close': 'Đóng',
      'viewFront': 'Xem mặt trước',
      'viewBack': 'Xem mặt sau',
      'flashcards': 'Flashcards',
      'cancel': 'Hủy',
      'noFlashcards': 'Chưa có flashcard nào',
      'importFromFile': 'Nhập từ file',
      'shuffleCards': 'Xáo trộn thẻ',
      'randomCard': 'Chọn ngẫu nhiên một thẻ',
      'loading': 'Đang nhập dữ liệu...',
      'noValidData': 'Không tìm thấy dữ liệu hợp lệ trong file.',
      'foundFlashcards': 'Đã tìm thấy {count} flashcard',
      'previewFirst5': 'Xem trước 5 thẻ đầu tiên:',
      'importData': 'Nhập dữ liệu',
      'addedNewFlashcards': 'Đã thêm {count} flashcard mới',
      'toggleTheme': 'Chuyển chế độ sáng/tối',
      'toggleLanguage': 'Chuyển ngôn ngữ',
      'selectingRandom': 'Tututu, đang chọn ngẫu nhiên đây :3',

    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String getWithArgs(String key, Map<String, dynamic> args) {
    String value = get(key);
    args.forEach((argKey, argValue) {
      value = value.replaceAll('{$argKey}', argValue.toString());
    });
    return value;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
