import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // IMPORT REQUIS
import 'dart:convert'; // IMPORT REQUIS

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
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
        _messageErreur = "Impossible de charger les données de l'utilisateur.";
      });
    }
  }

  // APPEL RÉEL AU BACKEND NODE.JS
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
        _messageErreur = "Impossible de joindre le serveur backend.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Historique des trajets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // LE COMPTEUR DEVIENT ENTIÈREMENT DYNAMIQUE BASE DE DONNÉES !
            Text(
              "${_courses.length} ${(_courses.length > 1) ? 'TRAJETS EFFECTUÉS' : 'TRAJET EFFECTUÉ'}",
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // GESTION DU CHARGEMENT, DE L'ERREUR OU DE LA LISTE VIDE
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
                        "Aucun trajet enregistré pour le moment.",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _courses.length,
                      itemBuilder: (context, index) {
                        final course = _courses[index];

                        // Formatage rapide de la date mysql en String lisible
                        String dateCourse =
                            course['date_course'] ?? "Date inconnue";
                        if (dateCourse.length > 10) {
                          dateCourse = dateCourse.substring(
                            0,
                            10,
                          ); // Extrait 'YYYY-MM-DD'
                        }

                        bool estAnnule = (course['statut'] == 'annulee');
                        String statutAffiche = "Terminé";
                        if (course['statut'] == 'en_attente')
                          statutAffiche = "En attente";
                        if (estAnnule) statutAffiche = "Annulé";

                        return _buildHistoryItem(
                          dateCourse,
                          course['arrivee'] ?? "Destination",
                          course['prix'] != null
                              ? "${course['prix']} F"
                              : "0 F",
                          statutAffiche,
                          isCancelled: estAnnule,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String date,
    String destination,
    String price,
    String status, {
    bool isCancelled = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCancelled
                  ? Colors.red.withOpacity(0.1)
                  : const Color(0xFF7B61FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCancelled ? Icons.close : Icons.directions_car,
              color: isCancelled ? Colors.redAccent : const Color(0xFF7B61FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: isCancelled ? Colors.white24 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: isCancelled ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
