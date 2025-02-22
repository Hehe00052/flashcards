import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/flashcard.dart';
import '../widgets/flashcard_widget.dart';
import '../utils/file_loader.dart';
import '../utils/random_card_selector.dart';
import '../utils/flashcard_operations.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../translations/app_localizations.dart';
import '../widgets/home_app_bar_actions.dart';  

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
    List<Flashcard> loadedFlashcards = await FileLoader.loadFlashcards(context: context);
    setState(() {
      flashcards = loadedFlashcards;
    });
  }

  Future<void> _importFlashcards() async {
    final appLocalizations = AppLocalizations.of(context);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(appLocalizations.get('loading')),
                ],
              ),
            );
          },
        );

        List<Flashcard> importedCards = await FileLoader.importFlashcardsFromFile(file, context: context);

        Navigator.pop(context);

        if (importedCards.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(appLocalizations.get('noValidData')),
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => _buildImportDialog(importedCards),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.getWithArgs(
              'errorImportingFile',
              {'error': e.toString()},
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImportDialog(List<Flashcard> importedCards) {
    final appLocalizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(
        appLocalizations.getWithArgs(
          'foundFlashcards',
          {'count': importedCards.length},
        ),
      ),
      content: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appLocalizations.get('previewFirst5')),
              const SizedBox(height: 8),
              ...importedCards.take(5).map((card) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${appLocalizations.get('front')}: ${card.front}"),
                        Text("${appLocalizations.get('back')}: ${card.back}"),
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
          child: Text(appLocalizations.get('cancel')),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              flashcards.addAll(importedCards);
            });
            await FileLoader.saveFlashcards(flashcards, context: context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appLocalizations.getWithArgs(
                    'addedNewFlashcards',
                    {'count': importedCards.length},
                  ),
                ),
              ),
            );
          },
          child: Text(appLocalizations.get('importData')),
        ),
      ],
    );
  }

  Future<void> _addFlashcard() async {
    await FlashcardOperations.addFlashcard(
      context: context,
      flashcards: flashcards,
      onUpdate: (updatedCards) => setState(() => flashcards = updatedCards),
    );
  }

  Future<void> _editFlashcard(Flashcard card) async {
    await FlashcardOperations.editFlashcard(
      context: context,
      card: card,
      flashcards: flashcards,
      onUpdate: (updatedCards) => setState(() => flashcards = updatedCards),
    );
  }

  Future<void> _removeFlashcard(Flashcard card) async {
    await FlashcardOperations.removeFlashcard(
      context: context,
      card: card,
      flashcards: flashcards,
      onUpdate: (updatedCards) => setState(() => flashcards = updatedCards),
    );
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
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.get('flashcards')),
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
  return [
    HomeAppBarActions(
      isSmallScreen: isSmallScreen,
      showExtraText: _showExtraText,
      onImportFlashcards: _importFlashcards,
      onToggleExtraText: () {
        setState(() {
          _showExtraText = !_showExtraText;
        });
      },
      onShuffleFlashcards: _shuffleFlashcards,
      onShowRandomFlashcard: _showRandomFlashcard,
    ),
  ];
}

  Widget _buildDrawer() {
    final appLocalizations = AppLocalizations.of(context);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(appLocalizations.get('toggleLanguage')),
              onTap: () {
                Provider.of<SettingsProvider>(context, listen: false).toggleLanguage();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: Text(appLocalizations.get('importFromFile')),
              onTap: () {
                Navigator.pop(context);
                _importFlashcards();
              },
            ),
            ListTile(
              leading: Icon(_showExtraText ? Icons.visibility : Icons.visibility_off),
              title: Text(
                _showExtraText
                    ? appLocalizations.get('hideExtraText')
                    : appLocalizations.get('showExtraText'),
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
              title: Text(appLocalizations.get('shuffleCards')),
              onTap: () {
                _shuffleFlashcards();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.casino),
              title: Text(appLocalizations.get('randomCard')),
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
    final appLocalizations = AppLocalizations.of(context);

    if (flashcards.isEmpty) {
      return Center(
        child: Text(
          appLocalizations.get('noFlashcards'),
          style: TextStyle(
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

        int columnCount;
        if (screenWidth < 400) {
          columnCount = 1;
        } else if (screenWidth < 700) {
          columnCount = 2;
        } else if (screenWidth < 1100) {
          columnCount = 3;
        } else {
          columnCount = 4;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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