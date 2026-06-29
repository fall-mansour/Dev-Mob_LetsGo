import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _nombreTrajets = 0;
  bool _isLoadingTrajets = true;
  bool _isProfileLoaded = false;

  // Données de l'utilisateur connecté
  String _prenom = "Chargement...";
  String _nom = "";
  String _telephone = "";
  String _email = "";
  int _idUtilisateur = 0;

  // CORRECTION CRITIQUE : URL locale pour Firefox (Flutter Web)
  final String _urlApiBase = "http://localhost:3000/api";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isProfileLoaded) {
      // 1. Récupération des arguments passés lors du clic sur l'accueil
      final Map<String, dynamic>? profilArguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (profilArguments != null) {
        setState(() {
          _idUtilisateur = profilArguments['id'] ?? 0;
          _prenom = profilArguments['prenom'] ?? "";
          _nom = profilArguments['nom'] ?? "";
          _telephone = profilArguments['telephone'] ?? "";
          _email = profilArguments['email'] ?? "";
          _isProfileLoaded = true;
        });

        // 2. Lancement des requêtes vers le serveur Node.js local
        _chargerProfilDepuisServeur(_idUtilisateur);
        _recupererNombreTrajets(_idUtilisateur);
      }
    }
  }

  // REQUÊTE GET : Force la récupération des infos fraîches de la BD
  Future<void> _chargerProfilDepuisServeur(int id) async {
    final String urlProfil = "$_urlApiBase/profil/$id";
    try {
      final response = await http.get(Uri.parse(urlProfil));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false && data['profil'] != null) {
          final p = data['profil'];
          setState(() {
            _prenom = p['prenom'] ?? "";
            _nom = p['nom'] ?? "";
            _telephone = p['telephone'] ?? "";
            _email = p['email'] ?? "";
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur chargement profil serveur : $e");
    }
  }

  // REQUÊTE GET : Badge de l'historique
  Future<void> _recupererNombreTrajets(int id) async {
    final String urlHistorique = "$_urlApiBase/courses/historique/client/$id";
    try {
      final response = await http.get(Uri.parse(urlHistorique));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List courses = data['courses'] ?? [];
        setState(() {
          _nombreTrajets = courses.length;
          _isLoadingTrajets = false;
        });
      } else {
        setState(() => _isLoadingTrajets = false);
      }
    } catch (e) {
      setState(() => _isLoadingTrajets = false);
      debugPrint("Erreur récupération trajets : $e");
    }
  }

  // REQUÊTE PUT : Enregistrement des modifications dans MySQL
  Future<void> _mettreAJourProfilEnLigne(
    String nouveauPrenom,
    String nouveauNom,
    String nouvelEmail,
  ) async {
    final String urlModification = "$_urlApiBase/profil/$_idUtilisateur";

    try {
      final response = await http.put(
        Uri.parse(urlModification),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "prenom": nouveauPrenom,
          "nom": nouveauNom,
          "email": nouvelEmail,
          "adresse": null,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _prenom = nouveauPrenom;
          _nom = nouveauNom;
          _email = nouvelEmail;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Modifications enregistrées dans la base de données ! 🎉",
              ),
              backgroundColor: Color(0xFF7B61FF),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la modification : $e");
    }
  }

  void _ouvrirDialogueModification() {
    final controllerPrenom = TextEditingController(text: _prenom);
    final controllerNom = TextEditingController(text: _nom);
    final controllerEmail = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16192B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Modifier le profil",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllerPrenom,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Prénom",
                labelStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerNom,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nom",
                labelStyle: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerEmail,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B61FF),
            ),
            onPressed: () {
              final nvPrenom = controllerPrenom.text.trim();
              final nvNom = controllerNom.text.trim();
              final nvEmail = controllerEmail.text.trim();

              if (nvPrenom.isNotEmpty && nvNom.isNotEmpty) {
                Navigator.pop(context);
                _mettreAJourProfilEnLigne(nvPrenom, nvNom, nvEmail);
              }
            },
            child: const Text(
              "Enregistrer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil Utilisateur",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MON COMPTE",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _menuItem(
                    Icons.person_outline,
                    "Informations personnelles",
                    onTap: _ouvrirDialogueModification,
                  ),

                  _menuItem(
                    Icons.history,
                    "Historique des trajets",
                    badge: _isLoadingTrajets ? "..." : "$_nombreTrajets",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/historique',
                        arguments: {
                          "id": _idUtilisateur,
                          "prenom": _prenom,
                          "nom": _nom,
                          "telephone": _telephone,
                          "email": _email,
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "PRÉFÉRENCES",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _menuItem(Icons.payment, "Paiement"),
                  _menuItem(Icons.notifications_none, "Notifications"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1D2E), Color(0xFF0B0D17)],
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF16192B),
            child: Icon(
              Icons.account_circle,
              size: 60,
              color: Color(0xFF7B61FF),
            ),
          ),
          const SizedBox(height: 15),

          // NOM COMPLET EN TOUTES LETTRES
          Text(
            "$_prenom $_nom",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _telephone.isNotEmpty ? _telephone : "Aucun numéro lié",
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    String? badge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                color: const Color(0xFF1F2235),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF7B61FF), size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2235),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF7B61FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
