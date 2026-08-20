import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/courrier_list_view.dart';
import 'package:courrier_mobile/services/courriers/courrier_service.dart';
import 'package:flutter/material.dart';
import 'courrier_form.dart';

class CourrierSelectTemplate extends StatefulWidget {
  const CourrierSelectTemplate({super.key});

  @override
  State<CourrierSelectTemplate> createState() => _CourrierSelectTemplateState();
}

class _CourrierSelectTemplateState extends State<CourrierSelectTemplate> {
  final TextEditingController searchController = TextEditingController();
  
  bool loading = false;
  Courrier? courrierSelected;
  bool openForm = false;
  List<Courrier> courriers = []; 
  bool _hasMoreCourriers = true;
  static const int nbLimitCourrier = 10; // Attention : 2 est peut-être trop bas pour tester

  @override
  void initState() {
    super.initState();
    _initCourriers();
  }

  Future<void> _initCourriers() async {
    setState(() => loading = true);
    try {
      final data = await getCourrier();
      // debugPrint('✅ Nombre de courriers récupérés: ${data.length}');

      setState(() {
        courriers = data;
        _hasMoreCourriers = data.length >= nbLimitCourrier;
      });
    } catch (e) {
      // ⚠️ IMPORTANT: Afficher l'erreur pour savoir pourquoi c'est vide
      debugPrint('❌ Erreur _initCourriers: $e'); 
    } finally {
      setState(() => loading = false);
    }
  }

  // 1. CORRECTION ICI : La vraie logique de recherche API
  Future<void> handleSearch() async {
    setState(() {
      loading = true;
    });
    
    try {
      final data = await getCourrier(
        reference: searchController.text.isEmpty ? null : searchController.text
      );
      
      setState(() {
        courriers = data;
        _hasMoreCourriers = data.length >= nbLimitCourrier;
      });
    } catch (e) {
      debugPrint('❌ Erreur handleSearch: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadMoreCourriers() async {
    if (loading || !_hasMoreCourriers || courriers.isEmpty) return;

    // 2. CORRECTION ICI : Assurez-vous que createdAt est bien converti en String si c'est un DateTime
    final lastDateObj = courriers.last.createdAt; 
    final lastDate = lastDateObj is DateTime ? lastDateObj.toString() : lastDateObj.toString();

    if (lastDate.isNotEmpty) {
      try {
        setState(() => loading = true);

        final newItems = await getCourrier(
          reference: searchController.text.isEmpty ? null : searchController.text, 
          lastDate: lastDate, 
        );

        setState(() {
          courriers.addAll(newItems);
          _hasMoreCourriers = newItems.length >= nbLimitCourrier;
        });
      } catch (e) {
        debugPrint('❌ Erreur loadMoreCourriers: $e');
      } finally {
        setState(() => loading = false);
      }
    }
  }

  void handleEdit(Courrier courrier) {
    setState(() {
      courrierSelected = courrier;
      openForm = true;
    });
  }

  void handleSuccess() {
    setState(() {
      openForm = false;
      courrierSelected = null;
    });
    _initCourriers(); // Optionnel : Recharger la liste après un succès
  }

  @override
  Widget build(BuildContext context) {
    if (openForm) {
      return CourrierForm(
        courrier: courrierSelected,
        onSuccess: handleSuccess,
        onClose: () => setState(() => openForm = false),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par référence...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: handleSearch, // Appelle maintenant la fonction corrigée
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Rechercher', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 3. ATTENTION ICI : Assurez-vous que le parent a une hauteur !
          Expanded(
            child: loading && courriers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : CourrierListView(
                    key: const PageStorageKey('courrier_list_scroll'), // 👈
                    courriers: courriers,
                    onSelect: handleEdit, 
                    isUpdate: true,
                    loading: loading && courriers.isEmpty,
                  ),
          ),
          if (_hasMoreCourriers && courriers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              onPressed: loading ? null : loadMoreCourriers,
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Afficher plus de courriers"),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<List<Courrier>> getCourrier({String? reference, String? lastDate}) async {
    return await CourrierService().getCourriers(reference: reference, dateCursor: lastDate);
  }
}