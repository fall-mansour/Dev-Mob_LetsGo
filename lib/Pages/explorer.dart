import 'package:flutter/material.dart';

class ExplorerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _backButton(context),
                  const SizedBox(width: 20),
                  const Text(
                    "Où allons-nous ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildItineraryInputs(),
            const SizedBox(height: 20),
            _buildQuickFilters(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "RECENTS",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _recentTile(
                    "Marché Sandaga",
                    "Plateau, Dakar",
                    "1.2 km",
                    Icons.access_time,
                  ),
                  _recentTile(
                    "Hôpital Principal",
                    "Rue Calmette, Dakar",
                    "3.4 km",
                    Icons.location_on,
                  ),
                  _recentTile(
                    "Aéroport AIBD",
                    "Diass, 45 km",
                    "45 km",
                    Icons.directions_bus,
                    isHighlight: true,
                  ),
                  _recentTile(
                    "Villa Almadies",
                    "Almadies, Dakar",
                    "8.1 km",
                    Icons.home,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "SUGGESTIONS",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _suggestionTile("Point E, Dakar"),
                  _suggestionTile("Université Cheikh Anta Diop"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF16192B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildItineraryInputs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _inputRow(
            "Ma position actuelle",
            Colors.blueAccent,
            Icons.my_location,
          ),
          const Divider(color: Colors.white10, height: 30),
          _inputRow(
            "Entrez votre destination...",
            Colors.greenAccent,
            Icons.mic,
            isMic: true,
          ),
        ],
      ),
    );
  }

  Widget _inputRow(
    String text,
    Color dotColor,
    IconData icon, {
    bool isMic = false,
  }) {
    return Row(
      children: [
        Icon(Icons.circle, color: dotColor, size: 10),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: isMic ? Colors.white38 : Colors.white),
          ),
        ),
        if (isMic)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7B61FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          )
        else
          Icon(icon, color: Colors.white38, size: 18),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          _filterChip(Icons.home, "Maison"),
          _filterChip(Icons.business_center, "Bureau"),
          _filterChip(Icons.location_on, "Aéroport"),
        ],
      ),
    );
  }

  Widget _filterChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7B61FF), size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _recentTile(
    String title,
    String sub,
    String dist,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: isHighlight ? const EdgeInsets.all(15) : EdgeInsets.zero,
      decoration: isHighlight
          ? BoxDecoration(
              color: const Color(0xFF16192B),
              borderRadius: BorderRadius.circular(15),
            )
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2235),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isHighlight ? Colors.orange : Colors.white38,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            dist,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _suggestionTile(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white38, size: 18),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
