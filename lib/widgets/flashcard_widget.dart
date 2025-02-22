import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/flashcard.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class FlashcardWidget extends StatelessWidget {
  final Flashcard flashcard;
  final bool isFlipping;
  final VoidCallback onFlipStart;
  final VoidCallback onFlipEnd;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool showExtraText;

  const FlashcardWidget({
    super.key,
    required this.flashcard,
    required this.isFlipping,
    required this.onFlipStart,
    required this.onFlipEnd,
    required this.onDelete,
    required this.onEdit,
    required this.showExtraText,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on parent constraints
        final isSmallScreen = MediaQuery.of(context).size.width < 600;
        final cardWidth = _getResponsiveCardWidth(context);
        final cardHeight = cardWidth * 1.2; // Maintain aspect ratio
        final iconSize = isSmallScreen ? 18.0 : 22.0;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isFlipping ? 0.3 : 1.0,
          child: Card(
            margin: EdgeInsets.all(isSmallScreen ? 5 : 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width: cardWidth,
              height: cardHeight,
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                onFlip: onFlipStart,
                onFlipDone: (isFront) => onFlipEnd(),
                front: _buildCardSide(
                  flashcard.front, 
                  _getFrontCardColor(isDarkMode),
                  context,
                  cardWidth,
                  cardHeight,
                  iconSize,
                  true, // Include icons on front side
                  isDarkMode,
                ),
                back: _buildCardSide(
                  flashcard.back,
                  _getBackCardColor(isDarkMode),
                  context,
                  cardWidth,
                  cardHeight,
                  iconSize,
                  false, // Don't include icons on back side
                  isDarkMode,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Get theme-aware front card color
  Color _getFrontCardColor(bool isDarkMode) {
    return isDarkMode 
        ? const Color.fromARGB(255, 66, 100, 167) // Darker blue for dark mode
        : const Color.fromARGB(255, 192, 212, 247); // Original light blue
  }

  // Get theme-aware back card color
  Color _getBackCardColor(bool isDarkMode) {
    return isDarkMode 
        ? const Color.fromARGB(255, 204, 122, 0) // Darker orange for dark mode
        : Colors.orangeAccent; // Original orange accent
  }

  double _getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 400) {
      // Mobile portrait
      return screenWidth * 0.85;
    } else if (screenWidth < 600) {
      // Mobile landscape/small tablet
      return screenWidth * 0.45;
    } else if (screenWidth < 900) {
      // Tablet
      return screenWidth * 0.3;
    } else {
      // Desktop
      return screenWidth * 0.2;
    }
  }

  Widget _buildCardSide(
    String text, 
    Color color, 
    BuildContext context, 
    double width, 
    double height,
    double iconSize,
    bool includeIcons,
    bool isDarkMode,
  ) {
    List<String> parts = text.split(" /");
    final isSmallCard = width < 200;
    
    // Text color based on card background
    final textColor = _getContrastingTextColor(color);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Main content centered
          Center(
            child: Padding(
              padding: EdgeInsets.all(isSmallCard ? 8 : 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    parts[0],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmallCard ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  if (parts.length > 1 && showExtraText) ...[
                    SizedBox(height: isSmallCard ? 3 : 5),
                    Text(
                      "/${parts[1]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallCard ? 14 : 16,
                        fontStyle: FontStyle.italic,
                        color: textColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Only include icons if requested (front side only)
          if (includeIcons)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: textColor,
                      size: iconSize,
                    ),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(4),
                    onPressed: onEdit,
                    tooltip: "Chỉnh sửa",
                  ),
                  SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: textColor,
                      size: iconSize,
                    ),
                    constraints: BoxConstraints(),
                    padding: EdgeInsets.all(4),
                    onPressed: onDelete,
                    tooltip: "Xóa",
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to determine contrasting text color
  Color _getContrastingTextColor(Color backgroundColor) {
    // Calculate relative luminance using the formula
    double luminance = (0.299 * backgroundColor.red + 
                        0.587 * backgroundColor.green + 
                        0.114 * backgroundColor.blue) / 255;
    
    // Return white for dark backgrounds, black for light ones
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}