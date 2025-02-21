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
  bool _showExtraText = true;
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

  void _showRandomFlashcard() {
  if (flashcards.isEmpty) return;
  
  // Hiển thị hiệu ứng "đang chọn ngẫu nhiên"
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _buildRandomSelectionAnimation(context),
  );
}

Widget _buildRandomSelectionAnimation(BuildContext context) {
  // Sau 1.5 giây, chọn thẻ và hiển thị
  Future.delayed(const Duration(milliseconds: 1500), () {
    Navigator.of(context).pop(); // Đóng dialog animation
    _selectAndShowRandomCard();
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
          const Text(
            "Đang chọn ngẫu nhiên...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        // Hiệu ứng đang tải
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
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

void _selectAndShowRandomCard() {
  if (flashcards.isEmpty) return;
  
  int randomIndex = _random.nextInt(flashcards.length);
  setState(() {
    selectedFlashcard = flashcards[randomIndex];
    _showBackSide = false;
  });
  
  // Hiệu ứng xuất hiện thẻ
  _showFlashcardWithAnimation();
}

void _showFlashcardWithAnimation() {
  if (selectedFlashcard == null) return;
  
  List<String> frontParts = selectedFlashcard!.front.split(" /");
  List<String> backParts = selectedFlashcard!.back.split(" /");
  bool dialogShowExtraText = _showExtraText;

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
                  const Expanded(
                    child: Text("Tada, random trúng kái lày gòi nè :3"),
                  ),
                ],
              ),
              content: GestureDetector(
                onTap: () {
                  setState(() {
                    _showBackSide = !_showBackSide;
                  });
                  Navigator.pop(context);
                  _showFlashcardWithAnimation();
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _showBackSide 
                        ? [Colors.orange.shade300, Colors.orange.shade500]
                        : [Colors.blue.shade300, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showBackSide ? backParts[0] : frontParts[0],
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
                      if ((_showBackSide && backParts.length > 1 ||
                          !_showBackSide && frontParts.length > 1) &&
                          dialogShowExtraText) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _showBackSide
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
                  tooltip: dialogShowExtraText ? "Ẩn phần text phụ" : "Hiện phần text phụ",
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showBackSide 
                        ? Colors.blue.shade400 
                        : Colors.orange.shade400,
                  ),
                  onPressed: () {
                    setState(() {
                      _showBackSide = !_showBackSide;
                    });
                    Navigator.pop(context);
                    _showFlashcardWithAnimation();
                  },
                  child: Text(
                    _showBackSide ? "Xem mặt trước" : "Xem mặt sau",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      );
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
