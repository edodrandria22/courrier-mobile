import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:flutter/material.dart';
import 'package:courrier_mobile/services/utils/token_service.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final Utilisateur? user;
  final bool loading;
  final String? title;
  final VoidCallback? onMenuToggle;
  final bool showMenu;

  const Header({
    super.key,
    required this.user,
    this.loading = false,
    this.title,
    this.onMenuToggle,
    this.showMenu = false,
  });

  // Hauteur standard d'une AppBar en Flutter
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String get _initials {
    if (user?.nom == null || user!.nom.trim().isEmpty) return 'U';
    final parts = user!.nom.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _handleDefaultLogout(BuildContext context) async {
    try {
      await TokenService.logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Erreur lors de la déconnexion : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        title: Container(
          height: 18,
          width: 140,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0.5,
      scrolledUnderElevation: 0.5,
      automaticallyImplyLeading: false, // Empêche le bouton retour automatique

      // --- 1. Bouton Menu Hamburger ---
      leading: showMenu
          ? Builder(
              builder: (scaffoldContext) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: onMenuToggle ?? () => Scaffold.of(scaffoldContext).openDrawer(),
              ),
            )
          : null,

      // --- 2. Titre ---
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,

      // --- 3. Actions (Thème + Dropdown Utilisateur) ---
      actions: [
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          onSelected: (value) async {
            switch (value) {
              case 'settings':
                Navigator.pushNamed(context, '/message/profile/security');
                break;
              case 'numeroDepart':
                Navigator.pushNamed(context, '/message/profile/numeroDepart');
                break;
              case 'logout':
                await _handleDefaultLogout(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            // Informations utilisateur
            PopupMenuItem<String>(
              enabled: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user?.nom ?? ""} ${user?.prenom ?? ""}'.trim(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const PopupMenuDivider(),

            // Paramètres
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 18),
                  SizedBox(width: 12),
                  Text('Paramètres', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            // Numéro de départ (Masqué pour Admin)
            if (user?.role != 'Admin')
              const PopupMenuItem<String>(
                value: 'numeroDepart',
                child: Row(
                  children: [
                    Icon(Icons.tag, size: 18),
                    SizedBox(width: 12),
                    Text('Numéro de départ', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),

            // Déconnexion
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 12),
                  Text(
                    'Déconnexion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 4.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.shade600,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}