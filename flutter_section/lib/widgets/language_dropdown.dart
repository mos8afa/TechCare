import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String _selectedLanguage = 'English';
  bool _showDropdown = false;

  final List<String> _languages = ['English', 'العربية'];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showDropdown = !_showDropdown;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    color: Color(0xFF1D89E4),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedLanguage,
                    style: const TextStyle(
                      color: Color(0xFF1D89E4),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF1D89E4),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_showDropdown)
            Positioned(
              top: 40,
              right: 0,
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _languages.map((lang) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = lang;
                          _showDropdown = false;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: _selectedLanguage == lang
                              ? const Color(0xFFF7FAFC)
                              : Colors.transparent,
                        ),
                        child: Text(
                          lang,
                          style: TextStyle(
                            color: _selectedLanguage == lang
                                ? const Color(0xFF1D89E4)
                                : const Color(0xFF4A5568),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}