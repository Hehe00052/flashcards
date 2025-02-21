import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../utils/file_loader.dart';
import '../utils/random_card_selector.dart'; // Import file mới

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Flashcard> flashcards = [];
  Flashcard? flippingCard;
  Flashcard? selectedFlashcard;
  bool _showBackSide = false;
  bool _showExtraText = true;
  final Random _random = Random();
  final RandomCardSelector _randomCardSelector = RandomCardSelector(); // Khởi tạo

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    List<Flashcard> loadedFlashcards = await FileLoader.loadFlashcards();
    setState(() {
      flashcards = loadedFlashcards;
    });
  }

  Future<void> _addFlashcard() async {
    TextEditingController frontController = TextEditingController();
    TextEditingController backController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Thêm Flashcard"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: frontController,
                  decoration: const InputDecoration(labelText: "Mặt trước"),
                ),
                TextField(
                  controller: backController,
                  decoration: const InputDecoration(labelText: "Mặt sau"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Flashcard newCard = Flashcard(
                    front: frontController.text,
                    back: backController.text,
                  );
                  setState(() {
                    flashcards.add(newCard);
                  });
                  await FileLoader.saveFlashcards(flashcards);
                  Navigator.pop(context);
                },
                child: const Text("Thêm"),
              ),
            ],
          ),
    );
  }

  Future<void> _editFlashcard(Flashcard card) async {
    TextEditingController frontController = TextEditingController(
      text: card.front,
    );
    TextEditingController backController = TextEditingController(
      text: card.back,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Chỉnh sửa Flashcard"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: frontController,
                  decoration: const InputDecoration(labelText: "Mặt trước"),
                ),
                TextField(
                  controller: backController,
                  decoration: const InputDecoration(labelText: "Mặt sau"),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    card.front = frontController.text;
                    card.back = backController.text;
                  });
                  await FileLoader.saveFlashcards(flashcards);
                  Navigator.pop(context);
                },
                child: const Text("Lưu"),
              ),
            ],
          ),
    );
  }

  Future<void> _removeFlashcard(Flashcard card) async {
    setState(() {
      flashcards.remove(card);
    });
    await FileLoader.saveFlashcards(flashcards);
  }

  Future<void> _shuffleFlashcards() async {
    setState(() {
      flashcards.shuffle();
    });
  }

  // Phương thức này giờ chỉ gọi đến RandomCardSelector
  void _showRandomFlashcard() {
    if (flashcards.isEmpty) return;
    
    _randomCardSelector.showRandomFlashcard(
      context: context,
      flashcards: flashcards,
      showBackSide: _showBackSide,
      showExtraText: _showExtraText,
      onCardSelected: (selectedCard) {
        setState(() {
          selectedFlashcard = selectedCard;
          _showBackSide = false;
        });
      },
      onFlipCard: (newShowBackSide) {
        setState(() {
          _showBackSide = newShowBackSide;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        actions: [
          IconButton(
            icon: Icon(
              _showExtraText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _showExtraText = !_showExtraText;
              });
            },
            tooltip: _showExtraText ? "Ẩn phần text phụ" : "Hiện phần text phụ",
          ),

          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleFlashcards,
            tooltip: "Xáo trộn thẻ",
          ),
          IconButton(
            icon: const Icon(Icons.casino),
            onPressed: _showRandomFlashcard,
            tooltip: "Chọn ngẫu nhiên một thẻ",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
      body:
          flashcards.isEmpty
              ? const Center(child: Text("Chưa có flashcard nào"))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children:
                        flashcards.map((flashcard) {
                          return FlashcardWidget(
                            flashcard: flashcard,
                            isFlipping:
                                flippingCard != null &&
                                flippingCard != flashcard,
                            onFlipStart:
                                () => setState(() => flippingCard = flashcard),
                            onFlipEnd:
                                () => setState(() => flippingCard = null),
                            onDelete: () => _removeFlashcard(flashcard),
                            onEdit: () => _editFlashcard(flashcard),
                            showExtraText: _showExtraText,
                          );
                        }).toList(),
                  ),
                ),
              ),
    );
  }
}