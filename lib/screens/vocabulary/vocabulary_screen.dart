import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({Key? key}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _cardAnimation;

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Greetings', 'Food', 'Family', 'Numbers', 'Colors'];

  final Map<String, List<VocabularyItem>> _vocabularyData = {
    'All': [
      VocabularyItem('Sannu', 'Hello', 'Greetings', 'sahn-noo'),
      VocabularyItem('Na gode', 'Thank you', 'Greetings', 'nah goh-deh'),
      VocabularyItem('Yaya kake?', 'How are you?', 'Greetings', 'yah-yah kah-keh'),
      VocabularyItem('Shinkafa', 'Rice', 'Food', 'sheen-kah-fah'),
      VocabularyItem('Nama', 'Meat', 'Food', 'nah-mah'),
      VocabularyItem('Uwa', 'Mother', 'Family', 'oo-wah'),
      VocabularyItem('Uba', 'Father', 'Family', 'oo-bah'),
      VocabularyItem('Daya', 'One', 'Numbers', 'dah-yah'),
      VocabularyItem('Biyu', 'Two', 'Numbers', 'bee-yoo'),
      VocabularyItem('Fari', 'White', 'Colors', 'fah-ree'),
      VocabularyItem('Baki', 'Black', 'Colors', 'bah-kee'),
    ],
    'Greetings': [
      VocabularyItem('Sannu', 'Hello', 'Greetings', 'sahn-noo'),
      VocabularyItem('Na gode', 'Thank you', 'Greetings', 'nah goh-deh'),
      VocabularyItem('Yaya kake?', 'How are you?', 'Greetings', 'yah-yah kah-keh'),
      VocabularyItem('Yaya kike?', 'How are you? (female)', 'Greetings', 'yah-yah kee-keh'),
      VocabularyItem('Lafiya', 'Fine/Well', 'Greetings', 'lah-fee-yah'),
      VocabularyItem('Sai anjima', 'Goodbye', 'Greetings', 'sahy ahn-jee-mah'),
    ],
    'Food': [
      VocabularyItem('Shinkafa', 'Rice', 'Food', 'sheen-kah-fah'),
      VocabularyItem('Nama', 'Meat', 'Food', 'nah-mah'),
      VocabularyItem('Kifi', 'Fish', 'Food', 'kee-fee'),
      VocabularyItem('Kayan miya', 'Vegetables', 'Food', 'kah-yahn mee-yah'),
      VocabularyItem('Ruwa', 'Water', 'Food', 'roo-wah'),
      VocabularyItem('Madara', 'Milk', 'Food', 'mah-dah-rah'),
    ],
    'Family': [
      VocabularyItem('Uwa', 'Mother', 'Family', 'oo-wah'),
      VocabularyItem('Uba', 'Father', 'Family', 'oo-bah'),
      VocabularyItem('Ya', 'Brother/Son', 'Family', 'yah'),
      VocabularyItem('Ya\'a', 'Sister/Daughter', 'Family', 'yah-ah'),
      VocabularyItem('Kaka', 'Grandfather', 'Family', 'kah-kah'),
      VocabularyItem('Kaka', 'Grandmother', 'Family', 'kah-kah'),
    ],
    'Numbers': [
      VocabularyItem('Daya', 'One', 'Numbers', 'dah-yah'),
      VocabularyItem('Biyu', 'Two', 'Numbers', 'bee-yoo'),
      VocabularyItem('Uku', 'Three', 'Numbers', 'oo-koo'),
      VocabularyItem('Hudhu', 'Four', 'Numbers', 'hoo-dhoo'),
      VocabularyItem('Biyar', 'Five', 'Numbers', 'bee-yar'),
      VocabularyItem('Shida', 'Six', 'Numbers', 'shee-dah'),
    ],
    'Colors': [
      VocabularyItem('Fari', 'White', 'Colors', 'fah-ree'),
      VocabularyItem('Baki', 'Black', 'Colors', 'bah-kee'),
      VocabularyItem('Ja', 'Red', 'Colors', 'jah'),
      VocabularyItem('Shudi', 'Blue', 'Colors', 'shoo-dee'),
      VocabularyItem('Kore', 'Green', 'Colors', 'koh-reh'),
      VocabularyItem('Rawaya', 'Yellow', 'Colors', 'rah-wah-yah'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  List<VocabularyItem> get _filteredVocabulary {
    if (_selectedCategory == 'All') {
      return _vocabularyData.values.expand((list) => list).toList();
    }
    return _vocabularyData[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hausa Vocabulary',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(AppConstants.primaryGreen),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Color(0xFFFFFFFF), // white
            ],
          ),
        ),
        child: Column(
          children: [
            // Category Filter
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(AppConstants.darkText),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                  HapticFeedback.lightImpact();
                                },
                                backgroundColor: const Color(0xFFF3F4F6),
                                selectedColor: const Color(AppConstants.primaryGreen),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Vocabulary List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredVocabulary.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _cardAnimation,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final itemAnimation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _cardAnimation,
                              curve: Interval(
                                delay.clamp(0.0, 1.0),
                                (delay + 0.6).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          );

                          return Transform.scale(
                            scale: 0.8 + (itemAnimation.value * 0.2),
                            child: Opacity(
                              opacity: itemAnimation.value,
                              child: _buildVocabularyCard(_filteredVocabulary[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(VocabularyItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Word Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.hausaWord,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.primaryGreen),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.englishTranslation,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(AppConstants.darkText),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.primaryGreen).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.primaryGreen),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pronunciation
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.accentOrange).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Color(AppConstants.accentOrange),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.pronunciation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VocabularyItem {
  final String hausaWord;
  final String englishTranslation;
  final String category;
  final String pronunciation;

  VocabularyItem(
    this.hausaWord,
    this.englishTranslation,
    this.category,
    this.pronunciation,
  );
}
