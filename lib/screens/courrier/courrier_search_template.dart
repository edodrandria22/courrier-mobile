import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/screens/courrier/courrier_template.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/courrier_list_view.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/courrier_search_form.dart';
import 'package:courrier_mobile/screens/menu/header.dart';
import 'package:courrier_mobile/screens/menu/sidebar.dart';
import 'package:courrier_mobile/services/courriers/courrier_service.dart';
import 'package:courrier_mobile/services/utils/token_service.dart';
import 'package:flutter/material.dart';

// import 'package:courrier_mobile/widgets/sidebar.dart';
// import 'package:courrier_mobile/widgets/header.dart';

class CourrierSearchTemplate extends StatefulWidget {
  final Function(Courrier)? onCourrierSelect;

  const CourrierSearchTemplate({
    super.key,
    this.onCourrierSelect,
  });

  @override
  State<CourrierSearchTemplate> createState() => _CourrierSearchTemplateState();
}

class _CourrierSearchTemplateState extends State<CourrierSearchTemplate> {
  List<Courrier> _searchResults = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  bool _hasSearched = false;
  Courrier? _selectedCourrier;
  CourrierSearchCriteria? _searchCriteria;
  bool _hasMore = true;

  // 💡 Variables pour la gestion de l'utilisateur (à adapter selon ton State Management : Provider, Riverpod, etc.)
  bool _isLoadingUser = true;
  // int _currentUserId = 0;
  Utilisateur? user;

  Future<void> _loadUser() async {
    try {
      user = await TokenService.getUser();

      if (mounted) {
        setState(() {
          // _currentUserId = user?.id ?? 0;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  // L'équivalent de process.env.NEXT_PUBLIC_NB_LIMIT_COURRIERS
  final int _nbLimitCourrier = 2;

  Future<void> _handleSearch(CourrierSearchCriteria criteria) async {
    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
      _searchCriteria = criteria;
      _hasMore = true;
    });

    try {
      final results = await CourrierService().searchCourriers(criteria);
      
      setState(() {
        _searchResults = results;
        if (results.length < _nbLimitCourrier) {
          _hasMore = false;
        }
      });
    } catch (err) {
      _showToast('Erreur lors de la recherche');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (_loading || _loadingMore || !_hasMore || _searchCriteria == null) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final lastResult = _searchResults.isNotEmpty ? _searchResults.last : null;
      final dateCursor = lastResult?.dateMessage;

      final newResults = await CourrierService().searchCourriers(
        _searchCriteria!, 
        date: dateCursor
      );

      setState(() {
        if (newResults.isEmpty || newResults.length < _nbLimitCourrier) {
          _hasMore = false;
        }
        _searchResults.addAll(newResults);
      });
    } catch (err) {
      _showToast('Erreur lors du chargement des résultats supplémentaires');
    } finally {
      setState(() {
        _loadingMore = false;
      });
    }
  }

  void _handleCourrierSelect(Courrier courrier) {
    if (widget.onCourrierSelect != null) {
      widget.onCourrierSelect!(courrier);
    } else {
      setState(() {
        _selectedCourrier = courrier;
      });
    }
  }

  void _handleReset() {
    setState(() {
      _searchResults = [];
      _hasSearched = false;
      _searchCriteria = null;
      _hasMore = true;
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // 💡 1. L'ancien contenu du build est isolé ici pour gérer dynamiquement l'affichage
  // 💡 1. L'ancien contenu du build est isolé ici pour gérer dynamiquement l'affichage
  Widget _buildCurrentLevelView() {
    return IndexedStack(
      // Si aucun courrier n'est sélectionné, on affiche l'index 0 (la liste). Sinon, l'index 1 (le détail)
      index: _selectedCourrier == null ? 0 : 1,
      children: [
        // ==========================================
        // INDEX 0 : Vue du formulaire et des résultats
        // ==========================================
        SingleChildScrollView(
          // 💡 L'ajout d'une PageStorageKey garantit que Flutter mémorise le scroll
          key: const PageStorageKey<String>('courrier_search_scroll_position'),
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CourrierSearchForm(
                  onSearch: _handleSearch,
                  loading: _loading,
                  reinitialiser: _handleReset,
                  initialCriteria: _searchCriteria,
                ),
                const SizedBox(height: 24),
                if (_hasSearched) ...[
                  Text(
                    'Résultats (${_searchResults.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (!_loading && _error == null && _searchResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Aucun courrier trouvé pour ces critères',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  if (_searchResults.isNotEmpty) ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 250,
                      child: CourrierListView(
                        courriers: _searchResults,
                        loading: _loading,
                        error: _error,
                        onSelect: _handleCourrierSelect,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_hasMore)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: _loading ? null : _loadMoreResults,
                            icon: _loadingMore
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.keyboard_arrow_down, size: 18),
                            label: Text(_loadingMore ? 'Chargement...' : 'Afficher plus de résultats'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: _loading ? Colors.grey : Theme.of(context).primaryColor,
                              side: BorderSide(
                                color: _loading ? Colors.grey[300]! : Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ),

        // ==========================================
        // INDEX 1 : Vue détaillée du courrier
        // ==========================================
        // On utilise une condition ternaire car IndexedStack construit tous ses enfants.
        // Cela évite l'erreur du "!" sur _selectedCourrier quand il est null.
        _selectedCourrier != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCourrier = null),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Retour à la recherche',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CourrierTemplate(
                      initialCourrier: _selectedCourrier!,
                      isRecherche: true,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(), // Affiche un widget vide en fond quand on est sur la liste
      ],
    );
  }
  // 💡 2. Le Scaffold global avec intercepteur de retour en arrière
  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String currentRoute = '/courrierRecherche'; 

    return PopScope(
      // On autorise la sortie de la page (pop) UNIQUEMENT si on n'est pas dans le détail d'un courrier
      canPop: _selectedCourrier == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        // Si le système tente de revenir en arrière mais qu'un courrier est sélectionné
        if (_selectedCourrier != null) {
          setState(() => _selectedCourrier = null);
        }
      },
      child: Scaffold(
        drawer: Sidebar(
          user: user,
          currentRoute: currentRoute,
        ),
        appBar: Header(
          user: user,
          loading: _isLoadingUser,
          showMenu: true,
          title: _selectedCourrier == null
              ? 'Recherche'
              : (_selectedCourrier?.object ?? 'Détail Courrier'),
        ),
        body: SafeArea(
          child: _buildCurrentLevelView(),
        ),
      ),
    );
  }
}