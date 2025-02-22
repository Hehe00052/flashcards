import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../utils/file_loader.dart';
import '../utils/random_card_selector.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

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
  final RandomCardSelector _randomCardSelector = RandomCardSelector();

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

  Future<void> _importFlashcards() async {
    try {
      // Use file picker to select a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Đang nhập dữ liệu..."),
                ],
              ),
            );
          },
        );

        // Process the file
        List<Flashcard> importedCards =
            await FileLoader.importFlashcardsFromFile(file);

        // Pop loading dialog
        Navigator.pop(context);

        if (importedCards.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Không tìm thấy dữ liệu hợp lệ trong file."),
            ),
          );
          return;
        }

        // Show confirm dialog with preview
        showDialog(
          context: context,
          builder: (context) => _buildImportDialog(importedCards),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi nhập file: $e")));
    }
  }

  Widget _buildImportDialog(List<Flashcard> importedCards) {
    return AlertDialog(
      title: Text("Đã tìm thấy ${importedCards.length} flashcard"),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Xem trước 5 thẻ đầu tiên:"),
              const SizedBox(height: 8),
              ...importedCards.take(5).map((card) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Front: ${card.front}"),
                        Text("Back: ${card.back}"),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        TextButton(
          onPressed: () async {
            // Add imported cards to current collection
            setState(() {
              flashcards.addAll(importedCards);
            });
            // Save to file
            await FileLoader.saveFlashcards(flashcards);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Đã thêm ${importedCards.length} flashcard mới"),
              ),
            );
          },
          child: const Text("Nhập dữ liệu"),
        ),
      ],
    );
  }

  Future<void> _addFlashcard() async {
    TextEditingController frontController = TextEditingController();
    TextEditingController backController = TextEditingController();

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Thêm Flashcard"),
            content: Container(
              width: dialogWidth,
              child: Column(
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

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 400.0;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Chỉnh sửa Flashcard"),
            content: Container(
              width: dialogWidth,
              child: Column(
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashcards"),
        actions: _buildAppBarActions(isSmallScreen),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFlashcard,
        child: const Icon(Icons.add),
      ),
      drawer: isSmallScreen ? _buildDrawer() : null,
      body: _buildBody(isSmallScreen),
    );
  }

  List<Widget> _buildAppBarActions(bool isSmallScreen) {
    if (isSmallScreen) {
      return [
        IconButton(
          icon: Icon(
            Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            Provider.of<SettingsProvider>(context, listen: false).toggleTheme();
          },
          tooltip: "Chuyển chế độ sáng/tối",
        ),
      ];
    } else {
      return [
        IconButton(
          icon: Icon(
            Provider.of<SettingsProvider>(context).themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
          ),
          onPressed: () {
            Provider.of<SettingsProvider>(context, listen: false).toggleTheme();
          },
          tooltip: "Chuyển chế độ sáng/tối",
        ),
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () {
            Provider.of<SettingsProvider>(
              context,
              listen: false,
            ).toggleLanguage();
          },
          tooltip: "Chuyển ngôn ngữ",
        ),
        IconButton(
          icon: const Icon(Icons.file_upload),
          onPressed: _importFlashcards,
          tooltip: "Nhập từ file",
        ),
        IconButton(
          icon: Icon(_showExtraText ? Icons.visibility : Icons.visibility_off),
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
      ];
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Chuyển ngôn ngữ"),
              onTap: () {
                Provider.of<SettingsProvider>(
                  context,
                  listen: false,
                ).toggleLanguage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: const Text("Nhập từ file"),
              onTap: () {
                Navigator.pop(context);
                _importFlashcards();
              },
            ),
            ListTile(
              leading: Icon(
                _showExtraText ? Icons.visibility : Icons.visibility_off,
              ),
              title: Text(
                _showExtraText ? "Ẩn phần text phụ" : "Hiện phần text phụ",
              ),
              onTap: () {
                setState(() {
                  _showExtraText = !_showExtraText;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text("Xáo trộn thẻ"),
              onTap: () {
                _shuffleFlashcards();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino),
              title: const Text("Chọn ngẫu nhiên một thẻ"),
              onTap: () {
                Navigator.pop(context);
                _showRandomFlashcard();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isSmallScreen) {
    if (flashcards.isEmpty) {
      return Center(
        child: Text(
          "Chưa có flashcard nào",
          style: TextStyle(
            // Use the current theme's text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 5 : 10),
        child: _buildResponsiveGrid(isSmallScreen),
      ),
    );
  }

  Widget _buildResponsiveGrid(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Calculate optimal column count based on screen width
        int columnCount;
        if (screenWidth < 400) {
          columnCount = 1; // Mobile portrait
        } else if (screenWidth < 700) {
          columnCount = 2; // Mobile landscape/small tablet
        } else if (screenWidth < 1100) {
          columnCount = 3; // Tablet/small desktop
        } else {
          columnCount = 4; // Desktop
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            childAspectRatio: 0.9,
            crossAxisSpacing: isSmallScreen ? 5 : 10,
            mainAxisSpacing: isSmallScreen ? 5 : 10,
          ),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final flashcard = flashcards[index];
            return FlashcardWidget(
              flashcard: flashcard,
              isFlipping: flippingCard != null && flippingCard != flashcard,
              onFlipStart: () => setState(() => flippingCard = flashcard),
              onFlipEnd: () => setState(() => flippingCard = null),
              onDelete: () => _removeFlashcard(flashcard),
              onEdit: () => _editFlashcard(flashcard),
              showExtraText: _showExtraText,
            );
          },
        );
      },
    );
  }
}
