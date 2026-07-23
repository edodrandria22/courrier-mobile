import 'package:flutter/material.dart';
import 'login/login_page.dart';
// ==========================================
// 1. CONFIGURATION & DONNÉES DE L'APPLICATION
// ==========================================
class AppConfig {
  static const String name = "Mesupres Courrier";
  static const String subName = "Enseignement Supérieur";
  static const String badge = "PLATEFORME OFFICIELLE - Mesupres";
  static const String titleNormal = "Gestion de Courrier";
  static const String titleGradient = "Mesupres";
  static const String description = "Communiquez efficacement avec vos collègues. Envoyez, recevez et gérez vos courriers avec des pièces jointes de manière intuitive et sécurisée.";
  static const String email = "contact@espa-poly.mg";
  static const String address = "Vontovorona, Antananarivo 101";
  static final String copyright = "© ${DateTime.now().year}. Application Mesupres Courrier.";
  
  // Chemins des images (à ajouter dans ton dossier assets/ et dans pubspec.yaml)
  static const String logoPath = "assets/mesupres.jpg";
  static const String logoFooterPath = "assets/logo-edogsanmhr.png";
}

// Couleurs principales (équivalent de var(--primary) et var(--secondary))
class AppColors {
  static const Color primary = Color(0xFF1E40AF); // Bleu primaire
  static const Color secondary = Color(0xFF475569); // Gris secondaire
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
}

// ==========================================
// 2. COMPOSANT PRINCIPAL
// ==========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavBar(context),
              _buildHeroSection(context),
              _buildFeaturesSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // --- NAVIGATION ---
  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage(AppConfig.logoPath), // Assure-toi d'avoir l'image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppConfig.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    AppConfig.subName.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("Connexion"),
            ),
        ],
      ),
    );
  }

  // --- HERO SECTION ---
  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  AppConfig.badge,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Titre
          const Text(
            AppConfig.titleNormal,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
          ),
          
          // Titre avec Gradient
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, Colors.lightBlue],
            ).createShader(bounds),
            child: const Text(
              AppConfig.titleGradient,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          const Text(
            AppConfig.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5),
          ),
          
          const SizedBox(height: 32),
          
          // Boutons d'action
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text("Commencer maintenant", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                    ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text("Suivre un courrier", style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: AppColors.secondary,
                    side: const BorderSide(color: AppColors.secondary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- FEATURES SECTION ---
  Widget _buildFeaturesSection() {
    final features = [
      {'icon': Icons.mail, 'color': AppColors.primary, 'title': 'Courriers', 'desc': "Envoyez et recevez des courriers instantanés."},
      {'icon': Icons.search, 'color': AppColors.secondary, 'title': 'Recherche', 'desc': "Recherchez facilement selon vos critères."},
      {'icon': Icons.access_time, 'color': AppColors.primary, 'title': 'Temps Réel', 'desc': "Suivez l'état de vos courriers en direct."},
      {'icon': Icons.lock, 'color': AppColors.secondary, 'title': 'Sécurisé', 'desc': "Vos échanges sont chiffrés et protégés."},
    ];

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text(
            "Fonctionnalités Principales",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          // Affichage en grille 2x2 pour mobile
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8, // Ajuste la hauteur des cartes
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final f = features[index];
              return _FeatureCard(
                icon: f['icon'] as IconData,
                color: f['color'] as Color,
                title: f['title'] as String,
                description: f['desc'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- FOOTER ---
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            AppConfig.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          const Text(
            "Plateforme officielle du Mesupres.",
            style: TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
          const SizedBox(height: 24),
          const Text("NOUS CONTACTER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(AppConfig.email, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(AppConfig.address, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            AppConfig.copyright,
            style: const TextStyle(fontSize: 10, color: AppColors.secondary, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. WIDGET CARTE FONCTIONNALITÉ
// ==========================================
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 11, color: AppColors.secondary),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}