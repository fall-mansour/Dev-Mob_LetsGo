import 'package:flutter/material.dart';

class TrajetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Carte et tracé de l'itinéraire
          Center(
            child: Icon(
              Icons.map,
              color: Colors.white.withOpacity(0.05),
              size: 400,
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildDriverCard()),
        ],
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF16192B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF7B61FF),
                child: Text(
                  "MB",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Moussa Bâ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Toyota Corolla • DK-4521-AA",
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                    Row(
                      children:
                          List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              color: i < 4 ? Colors.orange : Colors.white10,
                              size: 14,
                            ),
                          )..add(
                            const Text(
                              " 4.9",
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
              _actionIcon(Icons.phone),
              const SizedBox(width: 10),
              _actionIcon(Icons.chat_bubble_outline),
            ],
          ),
          const SizedBox(height: 25),
          _buildProgressIndicator(),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox("4 min", "Temps restant", const Color(0xFF1F2235)),
              _statBox(
                "1.4 km",
                "Distance",
                const Color(0xFF10211B),
                textColor: Colors.greenAccent,
              ),
              _statBox(
                "1 200 F",
                "Montant",
                const Color(0xFF211B10),
                textColor: Colors.orangeAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2235),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.blueAccent, size: 10),
            const SizedBox(width: 10),
            const Text(
              "Ma position actuelle",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(left: 4),
          height: 20,
          width: 2,
          color: Colors.white10,
        ),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.greenAccent, size: 10),
            const SizedBox(width: 10),
            const Text(
              "Marché Sandaga, Plateau",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: 0.62,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF7B61FF)),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "62% du trajet",
            style: TextStyle(
              color: Color(0xFF7B61FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(
    String val,
    String label,
    Color bg, {
    Color textColor = Colors.white,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
