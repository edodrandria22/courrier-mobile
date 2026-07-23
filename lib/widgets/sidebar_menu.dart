import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:flutter/material.dart';

// Modèle simple pour définir un élément du menu
class MenuAction {
  final String id;
  final String name;
  final IconData icon;
  final String path;

  MenuAction({
    required this.id,
    required this.name,
    required this.icon,
    required this.path,
  });
}

class SidebarMenu extends StatelessWidget {
  final Utilisateur? user;
  final String currentRoute; // Ex: '/message/courrier'
  final Function(String path) onNavigate;

  const SidebarMenu({
    super.key,
    required this.user,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Définition des variables pour les actions
    final bool isAdmin = user?.role == 'Admin';
    final List<MenuAction> actionItems = [];
    final List<MenuAction> systemFolders = [];

    if (!isAdmin) {
      actionItems.addAll([
        MenuAction(id: 'new-courrier', name: 'Nouveau Courrier', icon: Icons.edit_document, path: '/message/courrier'),
        MenuAction(id: 'statistique', name: 'Statistique', icon: Icons.bar_chart, path: '/message/courrier/statistique'),
      ]);
      systemFolders.addAll([
        MenuAction(id: 'inbox', name: 'Boîte de réception', icon: Icons.mail_outline, path: '/message/courrier/receive'),
        MenuAction(id: 'send', name: 'Boîte d\'envoi', icon: Icons.send_outlined, path: '/message/courrier/send'),
        MenuAction(id: 'recherche', name: 'Recherche', icon: Icons.search, path: '/message/courrier/recherche'),
      ]);
    } else {
      actionItems.add(
        MenuAction(id: 'utilisateurs', name: 'Utilisateurs', icon: Icons.person_outline, path: '/message/utilisateurs'),
      );
      systemFolders.add(
        MenuAction(id: 'recherche', name: 'Recherche', icon: Icons.search, path: '/message/courrier/recherche'),
      );
    }

    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête : Logo Image & Nom Projet
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      'assets/mesupres.jpg', // ⚠️ N'oublie pas d'ajouter l'image dans pubspec.yaml
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_balance, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "MESUPRES",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      Text(
                        "Enseignement Supérieur",
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Zone défilable pour les menus
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Actions
                  _buildSectionTitle("ACTIONS"),
                  ...actionItems.map((item) => _buildMenuItem(item)),

                  const SizedBox(height: 24),

                  // Section Menu Principal
                  _buildSectionTitle("MENU PRINCIPAL"),
                  ...systemFolders.map((item) => _buildMenuItem(item)),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: const [
                Icon(Icons.security, size: 16, color: Colors.blue), // Couleur primaire
                SizedBox(width: 8),
                Text(
                  "MESUPRES SÉCURISÉ",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- WIDGETS UTILES POUR LE DESIGN ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuAction item) {
    final bool isActive = currentRoute == item.path;
    const primaryColor = Color(0xFF1E40AF); // Remplace par ta couleur primaire

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => onNavigate(item.path),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Indicateur latéral pour l'élément actif (la barre verticale)
              if (isActive)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),

              // Contenu du bouton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive ? primaryColor : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? primaryColor : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}