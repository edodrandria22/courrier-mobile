import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; // 👈 Nouvel import
import 'package:courrier_mobile/services/courriers/courrier_service.dart';
class PieceJointeCard extends StatefulWidget {
  final PieceJointe pj;
  /// Callback optionnel pour exécuter votre service de téléchargement/ouverture
  final Future<void> Function(PieceJointe pj, bool isInline)? onDownloadOrOpen;

  const PieceJointeCard({
    super.key,
    required this.pj,
    this.onDownloadOrOpen,
  });

  @override
  State<PieceJointeCard> createState() => _PieceJointeCardState();
}

class _PieceJointeCardState extends State<PieceJointeCard> {
  bool _loading = false;

  // Types de fichiers consultables directement
  static const List<String> _inlineTypes = ['application/pdf', 'image/'];

  bool get _isInlineType =>
      _inlineTypes.any((type) => widget.pj.type.startsWith(type));


  Future<void> _handleOpen() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      if (widget.onDownloadOrOpen != null) {
        await widget.onDownloadOrOpen!(widget.pj, _isInlineType);
      } else {
        // 1. Récupération du fichier via le service
        final fileData = await CourrierService().downloadFichier(widget.pj.id);
        
        final List<int> bytes = fileData.bytes; // Ou Uint8List
        final String fileName = fileData.filename;

        // 2. Écriture du fichier dans le répertoire temporaire de l'appareil
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // 3. Consultation / Ouverture du fichier
        if (_isInlineType) {
          // Ouvre le fichier (PDF, Image, etc.) directement avec l'application par défaut du téléphone
          await OpenFilex.open(filePath);
        } else {
          // Pour un téléchargement/ouverture de fichier standard
          final result = await OpenFilex.open(filePath);
          if (result.type != ResultType.done && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Impossible d'ouvrir le fichier : ${result.message}"),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de la récupération du fichier : $e"),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInline = _isInlineType;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icone + Infos du fichier (Nom & Type)
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.pj.nom,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.pj.type,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Bouton d'action (VOIR / TÉLÉCHARGER)
          TextButton(
            onPressed: _loading ? null : _handleOpen,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: theme.primaryColor,
            ),
            child: _loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isInline
                            ? Icons.open_in_new
                            : Icons.file_download_outlined,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isInline ? 'VOIR' : 'TÉLÉCHARGER',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}