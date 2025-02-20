import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/flashcard.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool isFlipping;
  final VoidCallback onFlipStart;
  final VoidCallback onFlipEnd;
  final VoidCallback onDelete;
  final VoidCallback onEdit; 

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.isFlipping,
    required this.onFlipStart,
    required this.onFlipEnd,
    required this.onDelete,
    required this.onEdit, 
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isFlipping ? 0.3 : 1.0,
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            FlipCard(
              direction: FlipDirection.HORIZONTAL,
              onFlip: onFlipStart,
              onFlipDone: (isFront) => onFlipEnd(),
              front: _buildCardSide(flashcard.front, const Color.fromARGB(255, 192, 212, 247)),
              back: _buildCardSide(flashcard.back, Colors.orangeAccent),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color.fromARGB(255, 129, 39, 102)), // ✏ Nút Edit
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), // 🗑 Nút Delete
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSide(String text, Color color) {
    List<String> parts = text.split(" /");

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            parts[0],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (parts.length > 1) ...[
            const SizedBox(height: 5),
            Text(
              "/${parts[1]}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
