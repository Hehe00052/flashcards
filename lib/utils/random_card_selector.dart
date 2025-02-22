import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flashcard.dart';
import '../translations/app_localizations.dart'; // Thêm import này để truy cập AppLocalizations

class RandomCardSelector {
  final Random _random = Random();

  /// Hiển thị animation chọn thẻ ngẫu nhiên và sau đó hiển thị thẻ được chọn
  void showRandomFlashcard({
    required BuildContext context,
    required List<Flashcard> flashcards,
    required bool showBackSide,
    required bool showExtraText,
    required Function(Flashcard selectedCard) onCardSelected,
    required Function(bool newShowBackSide) onFlipCard,
  }) {
    if (flashcards.isEmpty) return;

    // Hiển thị hiệu ứng "đang chọn ngẫu nhiên"
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildRandomSelectionAnimation(
        context: context,
        flashcards: flashcards,
        showBackSide: showBackSide,
        showExtraText: showExtraText,
        onCardSelected: onCardSelected,
        onFlipCard: onFlipCard,
      ),
    );
  }

  Widget _buildRandomSelectionAnimation({
    required BuildContext context,
    required List<Flashcard> flashcards,
    required bool showBackSide,
    required bool showExtraText,
    required Function(Flashcard selectedCard) onCardSelected,
    required Function(bool newShowBackSide) onFlipCard,
  }) {
    final appLocalizations = AppLocalizations.of(context); // Truy cập AppLocalizations

    // Sau 1.5 giây, chọn thẻ và hiển thị
    Future.delayed(const Duration(milliseconds: 900), () {
      Navigator.of(context).pop(); // Đóng dialog animation
      _selectAndShowRandomCard(
        context: context,
        flashcards: flashcards,
        showBackSide: showBackSide,
        showExtraText: showExtraText,
        onCardSelected: onCardSelected,
        onFlipCard: onFlipCard,
      );
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appLocalizations.get('selectingRandom'), // Sử dụng bản địa hóa
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              builder: (context, double value, child) {
                return Column(
                  children: [
                    // Progress indicator tròn
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Stack(
                        alignment: Alignment.center, // Ensure stack is centered
                        children: [
                          // Hiệu ứng các thẻ xoay
                          ...List.generate(5, (index) {
                            // Calculate radius for positioning
                            final radius = 35.0; // Distance from center
                            final angle = 2 * 3.14 * ((index / 5) + (value * 2));

                            // Calculate x,y position in circle
                            final x = radius * cos(angle);
                            final y = radius * sin(angle);

                            return Transform.translate(
                              offset: Offset(x, y),
                              child: Transform.rotate(
                                angle: angle,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: Container(
                                    height: 30,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade300,
                                          Colors.orange.shade300,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectAndShowRandomCard({
    required BuildContext context,
    required List<Flashcard> flashcards,
    required bool showBackSide,
    required bool showExtraText,
    required Function(Flashcard selectedCard) onCardSelected,
    required Function(bool newShowBackSide) onFlipCard,
  }) {
    if (flashcards.isEmpty) return;

    int randomIndex = _random.nextInt(flashcards.length);
    Flashcard selectedFlashcard = flashcards[randomIndex];
    onCardSelected(selectedFlashcard);

    // Hiệu ứng xuất hiện thẻ
    _showFlashcardWithAnimation(
      context: context,
      selectedFlashcard: selectedFlashcard,
      showBackSide: showBackSide,
      showExtraText: showExtraText,
      onFlipCard: onFlipCard,
    );
  }

  void _showFlashcardWithAnimation({
    required BuildContext context,
    required Flashcard selectedFlashcard,
    required bool showBackSide,
    required bool showExtraText,
    required Function(bool newShowBackSide) onFlipCard,
  }) {
    List<String> frontParts = selectedFlashcard.front.split(" /");
    List<String> backParts = selectedFlashcard.back.split(" /");
    bool dialogShowExtraText = showExtraText;

    final appLocalizations = AppLocalizations.of(context); // Truy cập AppLocalizations

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
              ),
              child: AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appLocalizations.get('randomCardSelected'), // Sử dụng bản địa hóa
                      ),
                    ),
                  ],
                ),
                content: GestureDetector(
                  onTap: () {
                    bool newShowBackSide = !showBackSide;
                    onFlipCard(newShowBackSide);
                    Navigator.pop(context);
                    _showFlashcardWithAnimation(
                      context: context,
                      selectedFlashcard: selectedFlashcard,
                      showBackSide: newShowBackSide,
                      showExtraText: showExtraText,
                      onFlipCard: onFlipCard,
                    );
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: showBackSide
                            ? [Colors.orange.shade300, Colors.orange.shade500]
                            : [Colors.blue.shade300, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showBackSide ? backParts[0] : frontParts[0],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black26,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        if ((showBackSide && backParts.length > 1 ||
                                !showBackSide && frontParts.length > 1) &&
                            dialogShowExtraText) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              showBackSide
                                  ? "/${backParts[1]}"
                                  : "/${frontParts[1]}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      dialogShowExtraText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        dialogShowExtraText = !dialogShowExtraText;
                      });
                    },
                    tooltip: dialogShowExtraText
                        ? appLocalizations.get('hideExtraText')
                        : appLocalizations.get('showExtraText'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(appLocalizations.get('close')),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: showBackSide
                          ? Colors.blue.shade400
                          : Colors.orange.shade400,
                    ),
                    onPressed: () {
                      bool newShowBackSide = !showBackSide;
                      onFlipCard(newShowBackSide);
                      Navigator.pop(context);
                      _showFlashcardWithAnimation(
                        context: context,
                        selectedFlashcard: selectedFlashcard,
                        showBackSide: newShowBackSide,
                        showExtraText: showExtraText,
                        onFlipCard: onFlipCard,
                      );
                    },
                    child: Text(
                      showBackSide
                          ? appLocalizations.get('viewFront')
                          : appLocalizations.get('viewBack'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}