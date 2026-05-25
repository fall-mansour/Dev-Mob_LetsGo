import 'package:flutter/material.dart';
// Importations de tes fichiers
import 'Pages/acceuil.dart';
import 'Pages/explorer.dart';
import 'Pages/trajet.dart';
import 'Pages/profil.dart';
import 'Pages/historique.dart'; // Import de la page historique

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LetsGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D17),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B61FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: const MainNavigationContainer(),
      routes: {
        '/explorer': (context) => ExplorerPage(),
        '/historique': (context) => const HistoriquePage(),
      },
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() =>
      _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  // Liste des pages mise à jour
  final List<Widget> _pages = [
    AccueilPage(), // Index 0 : Icône Accueil
    ExplorerPage(), // Index 1 : Icône Loupe
    TrajetPage(), // Index 2 : Bouton Central (Position)
    const HistoriquePage(), // Index 3 : Icône Trajets (Document) -> TON HISTORIQUE
    ProfilPage(), // Index 4 : Icône Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack permet de ne pas recharger les pages (conserve l'état de la carte)
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B0D17),
          selectedItemColor: const Color(0xFF7B61FF),
          unselectedItemColor: Colors.white30,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Explorer',
            ),
            // Bouton Central "Position"
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B61FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFF7B61FF), width: 1),
                ),
                child: const Icon(Icons.location_on, color: Color(0xFF7B61FF)),
              ),
              label: '',
            ),
            // ONGLET TRAJETS -> Pointe maintenant vers HistoriquePage
            const BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Trajets',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
