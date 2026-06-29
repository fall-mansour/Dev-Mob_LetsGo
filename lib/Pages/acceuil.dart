import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Auto-suggestion via l'API OpenStreetMap (Nominatim)
  Future<List<Map<String, dynamic>>> _obtenirSuggestions(String query) async {
    if (query.length < 3) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query,Dakar,Senegal&format=json&limit=5&addressdetails=1',
    );

    try {
      final response = await http
          .get(url, headers: {'User-Agent': 'letsgo_app_project'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data
            .map(
              (item) => {
                'name': item['display_name'],
                'lat': double.parse(item['lat']),
                'lon': double.parse(item['lon']),
              },
            )
            .toList();
      }
    } catch (e) {
      debugPrint("Erreur suggestions: $e");
    }
    return [];
  }

  // Déplacement de la carte et transition vers la page de trajet simulée
  void _deplacerVersPosition(double lat, double lon, String nomDestination) {
    final LatLng position = LatLng(lat, lon);
    _mapController.move(position, 15.0);

    // Petit message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Destination sélectionnée : $nomDestination"),
        backgroundColor: const Color(0xFF7B61FF),
        duration: const Duration(seconds: 2),
      ),
    );

    // ROUTAGE VERS LA PAGE TRAJET APRES 1.5 SECONDE
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/trajet',
          arguments: {
            "depart": "Ma position actuelle (Liberté 6)",
            "arrivee": nomDestination.split(',')[0], // Nom court du lieu
            "prix": "1 300",
            "chauffeur": "Moussa Bâ",
            "vehicule": "Toyota Corolla • DK-4521-AA",
            "note_chauffeur": "4.9",
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // RÉCUPÉRATION DYNAMIQUE DES DONNÉES DU PROFIL TRANSMISES PAR LA CONNEXION
    final Map<String, dynamic> profil =
        (ModalRoute.of(context)?.settings.arguments ??
                {
                  "id": 0,
                  "nom": "Utilisateur",
                  "prenom": "LetsGo",
                  "telephone": "",
                  "email": "",
                  "adresse": "",
                })
            as Map<String, dynamic>;

    String prenom = profil['prenom'] ?? "LetsGo";

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      body: Stack(
        children: [
          // 1. CARTE INTERACTIVE
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(14.7256, -17.4644), // Liberté 6, Dakar
                initialZoom: 15.0,
                maxZoom: 18.0,
                minZoom: 10.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.letsgo.app',
                ),
              ],
            ),
          ),

          // 2. VOILE SOMBRE ESTHÉTIQUE
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),

          // 3. CONTENU DE L'INTERFACE
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildHeader(), // Header épuré sans avatar
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
                  Text(
                    "Où allez-vous, $prenom ?", // Salutation personnalisée toujours active !
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  // BARRE DE RECHERCHE AVEC AUTOSUGGESTION
                  _buildAutoSuggestionSearchBar(),

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

  // --- Widget du Header épuré (Uniquement le logo et le titre) ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
    );
  }

  Widget _buildAutoSuggestionSearchBar() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _searchController,
      builder: (context, controller, focusNode) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF16192B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white38),
              const SizedBox(width: 15),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Où allons-nous à Dakar ?",
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(Icons.tune, color: Colors.white38, size: 20),
            ],
          ),
        );
      },
      suggestionsCallback: (search) async => await _obtenirSuggestions(search),
      decorationBuilder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF16192B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: child,
          ),
        );
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: const Icon(
            Icons.location_on,
            color: Color(0xFF7B61FF),
            size: 18,
          ),
          title: Text(
            suggestion['name']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        );
      },
      onSelected: (suggestion) {
        _searchController.text = suggestion['name']!;
        _deplacerVersPosition(
          suggestion['lat']!,
          suggestion['lon']!,
          suggestion['name']!,
        );
      },
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
        GestureDetector(
          onTap: () =>
              _deplacerVersPosition(14.7481, -17.5146, "Maison (Almadies)"),
          child: _routeCard(Icons.home, "Maison", "Dakar, Almadies"),
        ),
        GestureDetector(
          onTap: () =>
              _deplacerVersPosition(14.6675, -17.4344, "Bureau (Plateau)"),
          child: _routeCard(Icons.business_center, "Bureau", "Plateau, Centre"),
        ),
      ],
    );
  }

  Widget _routeCard(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16192B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
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
