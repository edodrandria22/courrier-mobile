import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/screens/menu/header.dart';
import 'package:courrier_mobile/screens/menu/sidebar.dart';
import 'package:courrier_mobile/services/courriers/courrier_service.dart';
import 'package:courrier_mobile/services/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- B. MODÈLES DE DONNÉES (À adapter selon votre vrai backend) ---
class ChartItem {
  final String name;
  final String description;
  final int value;
  final Color color;

  ChartItem(this.name, this.description, this.value, this.color);
}

// --- C. WIDGET PRINCIPAL ---
class StatistiquePage extends StatefulWidget {
  const StatistiquePage({Key? key}) : super(key: key);

  @override
  State<StatistiquePage> createState() => _StatistiquePageState();
}

class _StatistiquePageState extends State<StatistiquePage> {
  // L'équivalent de vos useState
  late DateTime dateDebut;
  late DateTime dateFin;
  
  bool loading = true;
  String? error;
  Statistique? statistique;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  bool _isLoadingUser = true;
  Utilisateur? user;

  Future<void> _loadUser() async {
    try {
      user = await TokenService.getUser();

      if (mounted) {
        setState(() {
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
  final String currentRoute = '/statistique'; // Route actuelle pour la Sidebar


  @override
  void initState() {
    super.initState();
    
    // Charger l'utilisateur
    _loadUser();
    
    // Initialisation dynamique : date du jour
    final today = DateTime.now();
    dateDebut = today;
    dateFin = today;
    
    // L'équivalent de votre useEffect (lancé au démarrage)
    _fetchStatistiques();
  }

  // Simulation de votre useStatistique().getStatistique()
  Future<void> _fetchStatistiques() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final strDebut = _dateFormat.format(dateDebut);
      final strFin = _dateFormat.format(dateFin);
      
      final result = await CourrierService().getStatistique(strDebut, strFin);
      
      setState(() {
        statistique = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des statistiques';
        loading = false;
      });
    }
  }

  void _handleSetToday() {
    setState(() {
      final today = DateTime.now();
      dateDebut = today;
      dateFin = today;
    });
    _fetchStatistiques(); // On relance la recherche après changement
  }

  // Ouvre le calendrier natif pour choisir une date
  Future<void> _selectDate(BuildContext context, bool isDebut) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? dateDebut : dateFin,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          dateDebut = picked;
        } else {
          dateFin = picked;
        }
      });
      _fetchStatistiques(); // Relance la recherche
    }
  }

  // Prépare les données pour le graphique, en filtrant les zéros comme dans React
  List<ChartItem> get _chartData {
    if (statistique == null) return [];
    
    final items = [
      ChartItem('Non traités', 'Courriers non traités', statistique!.nonTraite, const Color(0xFFFF4D4F)),
      ChartItem('Boîte de réception', 'Courriers reçus', statistique!.recu!, const Color(0xFF1890FF)),
      ChartItem('Boîte d\'envoi', 'Courriers envoyés', statistique!.envoye!, const Color(0xFF52C41A)),
      ChartItem('Traités', 'Courriers traités', statistique!.traite!, const Color(0xFFFAAD14)),
      ChartItem('Arrivée', 'Courriers arrivés', statistique!.lu!, const Color(0xFF722ED1)),
      ChartItem('En route', 'Envoyés par un autre utilisateur', statistique!.nonLu!, const Color(0xFFEB2F96)),
    ];
    
    return items.where((item) => item.value > 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _chartData;
    
    // 1. Affichage du chargement utilisateur
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Retourne le Scaffold principal unifié
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      // --- SIDEBAR ---
      drawer: Sidebar(
        user: user,
        currentRoute: currentRoute,
      ),
      
      // --- HEADER PERSONNALISÉ ---
      appBar: Header(
        user: user,
        loading: _isLoadingUser,
        showMenu: true,
        title: 'Tableau de bord', // J'ai remplacé "Enregistrement" par "Tableau de bord" pour correspondre à la page
      ) as PreferredSizeWidget, 
      
      // --- CORPS DE LA PAGE (BODY) ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ZONE DES FILTRES ---
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                _buildDatePicker('Date début', dateDebut, () => _selectDate(context, true)),
                _buildDatePicker('Date fin', dateFin, () => _selectDate(context, false)),
                OutlinedButton(
                  onPressed: _handleSetToday,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Aujourd\'hui'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- ZONE DU GRAPHIQUE ---
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator()) // Animation de chargement
                  : error != null
                      ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                      : data.isEmpty
                          ? const Center(child: Text('Aucune donnée pour cette période.', style: TextStyle(color: Colors.grey)))
                          : _buildChartAndLegend(data),
            ),
          ],
        ),
      ),
    );
  }
  // Widget personnalisé pour les sélecteurs de date
  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_dateFormat.format(date)),
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Construit le graphique (Donut) et la légende
  Widget _buildChartAndLegend(List<ChartItem> data) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Le graphique en anneau
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 80, // Gère la taille du vide au centre (innerRadius)
                sections: data.map((item) {
                  return PieChartSectionData(
                    color: item.color,
                    value: item.value.toDouble(),
                    title: '${item.name}\n${item.value}',
                    radius: 60, // Gère l'épaisseur de l'anneau (outerRadius)
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // La légende (Grille responsive)
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: data.map((item) {
              return SizedBox(
                width: 150, // Largeur fixe pour faire un effet de grille
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 8),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(item.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}