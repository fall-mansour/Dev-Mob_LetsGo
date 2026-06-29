import 'dart:async'; // IMPORT REQUIS POUR LE TIMER
import 'package:flutter/material.dart';

class TrajetPage extends StatefulWidget {
  const TrajetPage({super.key});

  @override
  State<TrajetPage> createState() => _TrajetPageState();
}

class _TrajetPageState extends State<TrajetPage> {
  Timer? _timer;
  double _progression = 0.15; // Départ à 15% du trajet
  int _tempsRestant = 12; // 12 minutes estimées au départ
  double _distanceRestante = 4.8; // 4.8 km restants au départ

  @override
  void initState() {
    super.initState();
    _lancerSimulationTrajet();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Nettoyage du timer pour éviter les fuites de mémoire
    super.dispose();
  }

  // Simulation temps réel pour rendre l'écran vivant devant le jury
  void _lancerSimulationTrajet() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          if (_progression < 1.0) {
            _progression += 0.05; // Le trajet avance de 5% toutes les 4s

            // On réduit le temps et la distance proportionnellement
            if (_tempsRestant > 1) _tempsRestant -= 1;
            if (_distanceRestante > 0.2) _distanceRestante -= 0.3;
          } else {
            _progression = 1.0;
            _tempsRestant = 0;
            _distanceRestante = 0.0;
            _timer?.cancel();
            _afficherAlerteArrivee();
          }
        });
      }
    });
  }

  void _afficherAlerteArrivee() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Vous êtes arrivé à destination ! Merci d'avoir choisi letsgo.",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _obtenirInitiales(String nomChauffeur) {
    if (nomChauffeur.isEmpty) return "CH";
    List<String> mots = nomChauffeur.split(" ");
    if (mots.length >= 2) {
      return "${mots[0][0]}${mots[1][0]}".toUpperCase();
    }
    return mots[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // RÉCUPÉRATION DYNAMIQUE DES DONNÉES DE LA COURSE EN COURS
    final Map<String, dynamic> courseActive =
        (ModalRoute.of(context)?.settings.arguments ??
                {
                  "depart": "Ma position actuelle",
                  "arrivee": "Marché Sandaga, Plateau",
                  "prix": "1 200 F",
                  "chauffeur": "Moussa Bâ",
                  "vehicule": "Toyota Corolla • DK-4521-AA",
                  "note_chauffeur": "4.9",
                })
            as Map<String, dynamic>;

    String nomChauffeur = courseActive['chauffeur'] ?? "Chauffeur";
    String vehicule = courseActive['vehicule'] ?? "Véhicule LetsGo";
    String note = courseActive['note_chauffeur'] ?? "5.0";
    String prix = courseActive['prix']?.toString() ?? "1 200 F";
    if (!prix.contains('F')) prix = "$prix F";

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // Carte et tracé de l'itinéraire (Statique ou FlutterMap selon tes besoins d'affichage)
          Center(
            child: Icon(
              Icons.map,
              color: Colors.white.withOpacity(0.05),
              size: 400,
            ),
          ),

          // Bouton Retour pour quitter l'écran de suivi si besoin
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Carte du chauffeur fixe en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildDriverCard(
              nomChauffeur,
              vehicule,
              note,
              prix,
              courseActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(
    String chauffeur,
    String vehicule,
    String note,
    String prix,
    Map<String, dynamic> course,
  ) {
    String initiales = _obtenirInitiales(chauffeur);
    int pourcentageAffiche = (_progression * 100).toInt();

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
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF7B61FF),
                child: Text(
                  initiales, // Initiales dynamiques du chauffeur
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chauffeur, // Vrai nom
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      vehicule, // Vrai véhicule + matricule
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children:
                          List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              color: i < double.parse(note).floor()
                                  ? Colors.orange
                                  : Colors.white10,
                              size: 14,
                            ),
                          )..add(
                            Text(
                              " $note", // Vraie note
                              style: const TextStyle(
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
          _buildProgressIndicator(
            course['depart'] ?? "Ma position",
            course['arrivee'] ?? "Destination",
            pourcentageAffiche,
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statBox(
                "$_tempsRestant min",
                "Temps restant",
                const Color(0xFF1F2235),
              ),
              _statBox(
                "${_distanceRestante.toStringAsFixed(1)} km",
                "Distance",
                const Color(0xFF10211B),
                textColor: Colors.greenAccent,
              ),
              _statBox(
                prix, // Vrai prix dynamique issu de ta BDD / Sélection
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

  Widget _buildProgressIndicator(
    String depart,
    String arrivee,
    int pourcentage,
  ) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.blueAccent, size: 10),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                depart, // Adresse de départ dynamique
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
            Expanded(
              child: Text(
                arrivee, // Adresse d'arrivée dynamique
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        LinearProgressIndicator(
          value: _progression, // Progression animée
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation(Color(0xFF7B61FF)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            "$pourcentage% du trajet", // Pourcentage mis à jour en temps réel
            style: const TextStyle(
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
