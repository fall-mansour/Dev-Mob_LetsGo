import 'package:flutter/material.dart';

class AccueilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // 1. FOND DE CARTE (IMAGE)
          Positioned.fill(
            child: Image.asset(
              'assets/map_capture.png', // Assure-toi de nommer ton fichier ainsi dans ton dossier assets
              fit: BoxFit.cover,
            ),
          ),

          // 2. VOILE SOMBRE (Pour la lisibilité)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.4,
              ), // Ajuste l'opacité selon ton besoin
            ),
          ),

          // 3. CONTENU DE L'INTERFACE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  const Text(
                    "BON MATIN",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Où allez-vous ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(), // Laisse la carte visible au milieu

                  _buildSearchBar(context),
                  const SizedBox(height: 30),
                  const Text(
                    "TRAJETS RAPIDES",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildQuickRoutesGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets de construction ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hexagon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              "letsgo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          backgroundColor: Color(0xFF7B61FF),
          child: Text(
            "AK",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/explorer'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF16192B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white38),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                "Rechercher une destination...",
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const Icon(Icons.tune, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRoutesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _routeCard(Icons.home, "Maison", "Dakar, Almadies"),
        _routeCard(Icons.business_center, "Bureau", "Plateau, Centre"),
      ],
    );
  }

  Widget _routeCard(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7B61FF), size: 24),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
