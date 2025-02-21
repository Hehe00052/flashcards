import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:docx_to_text/docx_to_text.dart';
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
      return lines
          .map((line) {
            List<String> parts = line.split('|');
            if (parts.length == 2) {
              return Flashcard(front: parts[0].trim(), back: parts[1].trim());
            }
            return null;
          })
          .whereType<Flashcard>()
          .toList();
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

  static Future<List<Flashcard>> importFlashcardsFromFile(File file) async {
    try {
      String content;
      
      // Check file extension
      String extension = file.path.split('.').last.toLowerCase();
      
      if (extension == 'docx') {
        // Process Word document
        final bytes = await file.readAsBytes();
        content = docxToText(bytes);
      } else {
        // Process text file
        content = await file.readAsString();
      }
      
      List<String> lines = content.split('\n');
      List<Flashcard> newCards = [];
      
      for (String line in lines) {
        // Skip empty lines
        if (line.trim().isEmpty) continue;
        
        // Look for pattern with pipe separator
        int pipeIndex = line.indexOf('|');
        if (pipeIndex != -1) {
          String frontText = line.substring(0, pipeIndex).trim();
          String backText = line.substring(pipeIndex + 1).trim();
          newCards.add(Flashcard(front: frontText, back: backText));
        }
      }
      
      return newCards;
    } catch (e) {
      print('Lỗi khi nhập file: $e');
      return [];
    }
  }
}
