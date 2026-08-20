import 'package:courrier_mobile/screens/courrier/form/courrier_form.dart';
import 'package:courrier_mobile/screens/courrier/form/courrier_select.dart';
import 'package:courrier_mobile/screens/menu/header.dart';
import 'package:courrier_mobile/screens/menu/sidebar.dart';
import 'package:flutter/material.dart';

// N'oubliez pas d'importer vos composants Header et Sidebar
// import 'package:votre_projet/components/header.dart';
// import 'package:votre_projet/components/sidebar.dart';

class CourrierPage extends StatefulWidget {
  const CourrierPage({super.key});

  @override
  State<CourrierPage> createState() => _CourrierPageState();
}

class _CourrierPageState extends State<CourrierPage> {
  // Navigation interne ('form' ou 'template')
  String activeTab = 'form';
  
  // Variables nécessaires pour le Header et la Sidebar
  final bool _isLoadingUser = false; 
  dynamic user; // Remplacez 'dynamic' par votre modèle utilisateur (ex: UserModel)
  final String currentRoute = '/courrier'; // Route actuelle pour la Sidebar

  void handleTabChange(String tab) {
    setState(() {
      activeTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement si l'utilisateur n'est pas encore chargé
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      // 1. INJECTION DE LA SIDEBAR (MENU)
      drawer: Sidebar(
        user: user,
        currentRoute: currentRoute,
      ),
      
      // 2. INJECTION DU HEADER PERSONNALISÉ
      // Le composant Header attend une PreferredSizeWidget, nous supposons qu'il en hérite.
      appBar: Header(
        user: user,
        loading: _isLoadingUser,
        showMenu: true,
        title: 'Enregistrement', 
      ) as PreferredSizeWidget, 
      
      // 3. CORPS DE LA PAGE
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de page avec description et boutons d'onglets (déplacés ici)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enregistrer un nouveau courrier ou modifier un courrier enregistré.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  
                  // Menu d'onglets
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Nouveau', Icons.description_outlined, 'form'),
                        _buildTabButton('Modification', Icons.edit_document, 'template'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Séparateur subtil
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            // Contenu dynamique (Formulaire ou Liste)
            Expanded(
              child: activeTab == 'form' 
                  ? CourrierForm(onSuccess: () => handleTabChange('template'))
                  : const CourrierSelectTemplate(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personnalisé pour les boutons d'onglets
  Widget _buildTabButton(String label, IconData icon, String tabValue) {
    final isActive = activeTab == tabValue;
    
    return Expanded( // L'Expanded permet aux deux boutons de prendre 50% de la largeur chacun
      child: GestureDetector(
        onTap: () => handleTabChange(tabValue),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive 
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] 
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrage du contenu du bouton
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.blue[600] : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.blue[600] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}