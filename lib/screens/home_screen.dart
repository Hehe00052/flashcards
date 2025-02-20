import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../utils/file_loader.dart';

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
  final Random _random = Random();

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
      builder: (context) => AlertDialog(
        title: const Text("Thêm Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontController, decoration: const InputDecoration(labelText: "Mặt trước")),
            TextField(controller: backController, decoration: const InputDecoration(labelText: "Mặt sau")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Flashcard newCard = Flashcard(front: frontController.text, back: backController.text);
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
    TextEditingController frontController = TextEditingController(text: card.front);
    TextEditingController backController = TextEditingController(text: card.back);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa Flashcard"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: frontController, decoration: const InputDecoration(labelText: "Mặt trước")),
            TextField(controller: backController, decoration: const InputDecoration(labelText: "Mặt sau")),
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

  void _showRandomFlashcard() {
    if (flashcards.isNotEmpty) {
      int randomIndex = _random.nextInt(flashcards.length);
      setState(() {
        selectedFlashcard = flashcards[randomIndex];
        _showBackSide = false; // Ban đầu chỉ hiển thị mặt trước
      });
      _showFlashcardDialog();
    }
  }

  void _showFlashcardDialog() {
    if (selectedFlashcard == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tada, random trúng kái lày gòi nè :3"),
        content: GestureDetector(
          onTap: () {
            setState(() {
              _showBackSide = !_showBackSide;
            });
            Navigator.pop(context);
            _showFlashcardDialog();
          },
          child: Text(_showBackSide ? selectedFlashcard!.back : selectedFlashcard!.front,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        actions: [
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
      body: flashcards.isEmpty
          ? const Center(child: Text("Chưa có flashcard nào"))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: flashcards.map((flashcard) {
                    return FlashcardWidget(
                      flashcard: flashcard,
                      isFlipping: flippingCard != null && flippingCard != flashcard,
                      onFlipStart: () => setState(() => flippingCard = flashcard),
                      onFlipEnd: () => setState(() => flippingCard = null),
                      onDelete: () => _removeFlashcard(flashcard),
                      onEdit: () => _editFlashcard(flashcard),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}