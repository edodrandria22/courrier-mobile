import 'package:flutter/material.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/services/utils/token_service.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final Utilisateur? user;
  final bool loading;
  final String? title; // 👈 Ajout du titre
  final VoidCallback? onMenuToggle;
  final bool showMenu;
  final Future<void> Function()? onLogout;

  const Header({
    super.key,
    required this.user,
    this.loading = false,
    this.title,
    this.onMenuToggle,
    this.showMenu = false,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

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
      return _buildLoadingHeader(context);
    }

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SafeArea(
        child: Row(
          children: [
            // --- Bouton Hamburger ---
            if (showMenu)
              Builder(
                builder: (scaffoldContext) => IconButton(
                  icon: const Icon(Icons.menu, size: 22, color: Colors.black87),
                  onPressed: onMenuToggle ?? () => Scaffold.of(scaffoldContext).openDrawer(),
                  splashRadius: 20,
                ),
              ),

            // --- Titre Dynamique ---
            if (title != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            const SizedBox(width: 4),

            // --- Menu Déroulant Utilisateur ---
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
                    if (onLogout != null) {
                      await onLogout!();
                    } else {
                      await _handleDefaultLogout(context);
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                // Info Utilisateur
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

                // Option Paramètres
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

                // Option Numéro de départ (sauf si Admin)
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

                // Option Déconnexion
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
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue.shade600,
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showMenu)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}