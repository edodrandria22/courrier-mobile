import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final Utilisateur? user;
  final String currentRoute;

  const Sidebar({
    super.key,
    required this.user,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = user?.role == 'Admin';

    // Couleurs inspirées de votre capture d'écran
    const Color primaryTeal = Color(0xFF00B4A2);
    const Color activeBgTeal = Color(0xFFE0F7F5);

    final List<Map<String, dynamic>> actionItems = !isAdmin
        ? [
            {'id': 'new-courrier', 'name': 'Nouveau Courrier', 'icon': Icons.edit_document, 'path': '/courrier'},
            {'id': 'statistique', 'name': 'Statistique', 'icon': Icons.bar_chart, 'path': '/statistique'},
          ]
        : [
            {'id': 'utilisateurs', 'name': 'Utilisateurs', 'icon': Icons.person_outline, 'path': '/utilisateurs'},
          ];

    final List<Map<String, dynamic>> systemFolders = !isAdmin
        ? [
            {'id': 'inbox', 'name': 'Boîte de réception', 'icon': Icons.mail_outline, 'path': '/courrierReceive'},
            {'id': 'send', 'name': "Boîte d'envoi", 'icon': Icons.send_outlined, 'path': '/courrierSend'},
            {'id': 'recherche', 'name': 'Recherche', 'icon': Icons.search, 'path': '/courrierRecherche'},
          ]
        : [
            {'id': 'recherche', 'name': 'Recherche', 'icon': Icons.search, 'path': '/courrierRecherche'},
          ];

    return Drawer(
      width: 290, // Largeur du menu
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // --- En-tête avec Logo & Bouton Fermer (X) ---
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                ),
                child: Stack(
                  children: [
                    // Bouton Fermer (X) en haut à droite
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                        onPressed: () => Navigator.pop(context), // Ferme le menu
                      ),
                    ),
                    // Logo & Titre central
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 70,
                            child: Image.asset(
                              'assets/mesupres.jpg',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.account_balance,
                                size: 50,
                                color: primaryTeal,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "GESTION DE COURRIER",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Liste défilante des éléments de menu ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildSectionTitle('ACTIONS'),
                  const SizedBox(height: 6),
                  ...actionItems.map((item) => _buildMenuItem(context, item, primaryTeal, activeBgTeal)),
                  
                  const SizedBox(height: 20),
                  
                  _buildSectionTitle('MENU PRINCIPAL'),
                  const SizedBox(height: 6),
                  ...systemFolders.map((item) => _buildMenuItem(context, item, primaryTeal, activeBgTeal)),
                ],
              ),
            ),

            // --- Pied de page ---
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, size: 18, color: primaryTeal),
                  SizedBox(width: 8),
                  Text(
                    "MESUPRES SÉCURISÉ",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour le titre de section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade400,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  // Widget pour un élément du menu
  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item, Color primaryColor, Color activeBgColor) {
    final String path = item['path'];
    final String targetRoute = path.startsWith('/') ? path : '/$path';
    final bool isActive = currentRoute == targetRoute || currentRoute == path;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        onTap: () {
          // Ferme le drawer
          Navigator.pop(context);
          if (!isActive) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Indicateur latéral pour l'élément actif
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: isActive ? primaryColor : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                item['icon'],
                size: 22,
                color: isActive ? primaryColor : Colors.grey.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? primaryColor : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}