import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // IMPORT REQUIS
import 'dart:convert'; // IMPORT REQUIS

class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});

  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  String _messageErreur = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupération des données du profil passées en argument depuis la navigation
    final Map<String, dynamic>? profil =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (profil != null && profil['id'] != null) {
      _chargerHistoriqueCourses(profil['id']);
    } else {
      setState(() {
        _isLoading = false;
        _messageErreur = "Impossible de récupérer vos identifiants.";
      });
    }
  }

  // APPEL RÉEL VERS L'API BACKEND
  Future<void> _chargerHistoriqueCourses(int idUtilisateur) async {
    final String urlApi =
        "http://10.0.2.2:3000/api/courses/historique/client/$idUtilisateur";

    try {
      final response = await http.get(Uri.parse(urlApi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _courses = data['courses'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _messageErreur = "Erreur lors du chargement de l'historique.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messageErreur = "Impossible de joindre le serveur.";
        _isLoading = false;
      });
    }
  }

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
                    "Historique des courses",
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

            // AFFICHAGE DYNAMIQUE DE L'HISTORIQUE DE LA BASE DE DONNÉES
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7B61FF),
                      ),
                    )
                  : _messageErreur.isNotEmpty
                  ? Center(
                      child: Text(
                        _messageErreur,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    )
                  : _courses.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucune course enregistrée pour le moment.",
                        style: TextStyle(color: Colors.white38),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];
                        return _recentTile(
                          course['depart'] ?? "Départ inconnu",
                          course['arrivee'] ?? "Arrivée inconnue",
                          course['prix'] != null
                              ? "${course['prix']} FCFA"
                              : "Prix non fixé",
                          course['statut'] ?? "en_attente",
                        );
                      },
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

  // Tuile adaptative selon le statut réel provenant de la BDD
  Widget _recentTile(
    String depart,
    String arrivee,
    String prix,
    String statut,
  ) {
    IconData iconeStatut;
    Color couleurStatut;

    switch (statut) {
      case 'terminee':
        iconeStatut = Icons.check_circle_outline;
        couleurStatut = Colors.greenAccent;
        break;
      case 'annulee':
        iconeStatut = Icons.cancel_outlined;
        couleurStatut = Colors.redAccent;
        break;
      default:
        iconeStatut = Icons.access_time;
        couleurStatut = Colors.orangeAccent;
    }

    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2235),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconeStatut, color: couleurStatut, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arrivee,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "De : $depart",
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            prix,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
