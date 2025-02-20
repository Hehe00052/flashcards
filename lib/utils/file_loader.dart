import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/flashcard.dart';

class FileLoader {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/flashcards.txt');
  }

  static Future<List<Flashcard>> loadFlashcards() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return []; 
      }
      List<String> lines = await file.readAsLines();
      return lines.map((line) {
        List<String> parts = line.split('|');
        if (parts.length == 2) {
          return Flashcard(front: parts[0].trim(), back: parts[1].trim());
        }
        return null;
      }).whereType<Flashcard>().toList();
    } catch (e) {
      print('Lỗi khi đọc file: $e');
      return [];
    }
  }

  static Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    try {
      final file = await _getFile();
      String data = flashcards.map((f) => '${f.front} | ${f.back}').join('\n');
      await file.writeAsString(data);
    } catch (e) {
      print('Lỗi khi ghi file: $e');
    }
  }

  static Future<void> addFlashcard(Flashcard newCard) async {
    List<Flashcard> flashcards = await loadFlashcards();
    flashcards.add(newCard);
    await saveFlashcards(flashcards);
  }

  static Future<void> deleteFlashcard(int index) async {
    List<Flashcard> flashcards = await loadFlashcards();
    if (index >= 0 && index < flashcards.length) {
      flashcards.removeAt(index);
      await saveFlashcards(flashcards);
    }
  }
}
