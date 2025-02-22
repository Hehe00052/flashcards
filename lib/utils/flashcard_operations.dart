import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'file_loader.dart';
import '../translations/app_localizations.dart';

class FlashcardOperations {
  static Future<void> addFlashcard({
    required BuildContext context,
    required List<Flashcard> flashcards,
    required Function(List<Flashcard>) onUpdate,
  }) async {
    TextEditingController frontController = TextEditingController();
    TextEditingController backController = TextEditingController();

    final appLocalizations = AppLocalizations.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.get('addFlashcard')),
        content: Container(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: frontController,
                decoration: InputDecoration(labelText: appLocalizations.get('front')),
              ),
              TextField(
                controller: backController,
                decoration: InputDecoration(labelText: appLocalizations.get('back')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Flashcard newCard = Flashcard(
                front: frontController.text,
                back: backController.text,
              );
              flashcards.add(newCard);
              await FileLoader.saveFlashcards(flashcards, context: context);
              onUpdate(flashcards);
              Navigator.pop(context);
            },
            child: Text(appLocalizations.get('add')),
          ),
        ],
      ),
    );
  }

  static Future<void> editFlashcard({
    required BuildContext context,
    required Flashcard card,
    required List<Flashcard> flashcards,
    required Function(List<Flashcard>) onUpdate,
  }) async {
    TextEditingController frontController = TextEditingController(text: card.front);
    TextEditingController backController = TextEditingController(text: card.back);

    final appLocalizations = AppLocalizations.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.get('editFlashcard')),
        content: Container(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: frontController,
                decoration: InputDecoration(labelText: appLocalizations.get('front')),
              ),
              TextField(
                controller: backController,
                decoration: InputDecoration(labelText: appLocalizations.get('back')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              card.front = frontController.text;
              card.back = backController.text;
              await FileLoader.saveFlashcards(flashcards, context: context);
              onUpdate(flashcards);
              Navigator.pop(context);
            },
            child: Text(appLocalizations.get('save')),
          ),
        ],
      ),
    );
  }

  static Future<void> removeFlashcard({
    required Flashcard card,
    required List<Flashcard> flashcards,
    required Function(List<Flashcard>) onUpdate,
    required BuildContext context, // Định nghĩa rõ ràng tham số context
  }) async {
    flashcards.remove(card);
    await FileLoader.saveFlashcards(flashcards, context: context);
    onUpdate(flashcards);
  }
}