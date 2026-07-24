import 'dart:async';
import 'package:courrier_mobile/models/courrier/courrier.dart';
import 'package:courrier_mobile/models/utilisateur/utilisateur_model.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/courrier_list_view.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/message_detail_view.dart';
import 'package:courrier_mobile/screens/courrier/sousComposant/message_list_view.dart';
import 'package:courrier_mobile/services/courriers/courrier_service.dart';
import 'package:courrier_mobile/services/utils/token_service.dart';
import 'package:flutter/material.dart';

// Import de tes modèles et services
// import 'models.dart';

enum StepLevel { courriers, messages, detail }

class CourrierTemplate extends StatefulWidget {
  final Courrier? initialCourrier;
  final bool isRecherche;

  const CourrierTemplate({
    super.key,
    this.initialCourrier,
    this.isRecherche = false,
  });

  @override
  State<CourrierTemplate> createState() => _CourrierTemplateState();
}

class _CourrierTemplateState extends State<CourrierTemplate> {
  // Utilisateur? _currentUser;
  bool _isLoadingUser = true;
  int _currentUserId = 0;

  Future<void> _loadUser() async {
    final user = await TokenService.getUser();
    if (mounted) {
      setState(() {
        // _currentUser = user;
        _currentUserId = user?.id ?? 0;
        _isLoadingUser = false;
      });
    }
  }
  // Limites de pagination
  static const int nbLimitCourrier = 2;
  static const int nbLimitMessage = 2;

  // États principaux
  StepLevel _currentLevel = StepLevel.courriers;
  Courrier? _selectedCourrier;
  MessageCourrier? _selectedMessage;

  List<Courrier> _courriers = [];
  List<MessageCourrier> _messages = [];

  bool _loading = false;
  String? _error;

  bool _hasMoreCourriers = true;
  bool _hasMoreMessages = true;
  bool? _isTraiterAt;
  int _nbNonTraite = 0;

  // Abonnements temps réel (Équivalent Mercure)
  StreamSubscription? _messageSubscription;
  StreamSubscription? _lectureSubscription;
  StreamSubscription? _clotureSubscription;

  @override
  void initState() {
    super.initState();
    _loadUser();

    if (widget.initialCourrier != null) {
      _selectedCourrier = widget.initialCourrier;
      _currentLevel = StepLevel.messages;
      _initMessages(widget.initialCourrier!.id ?? 0);
    } else {
      _initCourriers();
    }

    _subscribeToMercureEvents();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _lectureSubscription?.cancel();
    _clotureSubscription?.cancel();
    super.dispose();
  }

  // --- API & CHARGEMENT ---

  Future<void> _initCourriers() async {
    setState(() => _loading = true);
    try {
      final data = await fetchCourriersByUser(isTraiterAt: _isTraiterAt);
      final countData = await getNbNonTraite();

      setState(() {
        _courriers = data;
        _nbNonTraite = countData;
        _hasMoreCourriers = data.length >= nbLimitCourrier;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadMoreCourriers() async {
    if (_loading || !_hasMoreCourriers || _courriers.isEmpty) return;

    final lastDate = _courriers.last.dateMessage;
    if (lastDate == null) return;

    setState(() => _loading = true);
    final newItems = await fetchCourriersByUser(
      lastDate: lastDate,
      isTraiterAt: _isTraiterAt,
    );

    setState(() {
      _courriers.addAll(newItems);
      if (newItems.length < nbLimitCourrier) {
        _hasMoreCourriers = false;
      }
      _loading = false;
    });
  }

  Future<void> _initMessages(int courrierId) async {
    setState(() {
      _loading = true;
      _hasMoreMessages = true;
    });

    final data = await fetchMessages(courrierId: courrierId);

    setState(() {
      _messages = data;
      if (data.length < nbLimitMessage) {
        _hasMoreMessages = false;
      }
      _loading = false;
    });
  }

  Future<void> _loadMoreMessages() async {
    if (_loading || !_hasMoreMessages || _selectedCourrier == null) return;

    final lastMsgDate = _messages.isNotEmpty ? _messages.last.createdAt : null;
    if (lastMsgDate == null) return;

    setState(() => _loading = true);
    final newMsgs = await fetchMessages(
      courrierId: _selectedCourrier!.id ?? 0,
      lastDate: lastMsgDate,
    );

    setState(() {
      _messages.addAll(newMsgs);
      if (newMsgs.length < nbLimitMessage) {
        _hasMoreMessages = false;
      }
      _loading = false;
    });
  }

  // --- ACTIONS ---

  void _handleMessageRead(int messageId) {
    final bool isMarkingUnread = messageId == 0;
    if (_currentLevel != StepLevel.detail || _selectedMessage == null) return;

    final targetId = isMarkingUnread ? _selectedMessage!.id : messageId;
    final newReadDate = isMarkingUnread ? null : DateTime.now().toIso8601String();

    setState(() {
      _messages = _messages.map((m) {
        return m.id == targetId ? m.copyWith(isReadAt: newReadDate) : m;
      }).toList();

      _selectedMessage = _selectedMessage!.copyWith(isReadAt: newReadDate);
    });
  }
  Future<Courrier> _updateHistorique(int courrierId, String observation) async {
    
    return Future.value(Courrier(
      id: courrierId, 
      observation: observation,
      object: '',
      detailPersonnes: []
    ));
  }

  Future<void> _handleLocalCloturation(int courrierId) async {
    try {
      final res = await cloturerCourrierApi(courrierId);
      if (res['success'] == true) {
        setState(() {
          _courriers = _courriers.map((c) {
            return c.id == courrierId ? c.copyWith(cloturePar: res['cloturePar']) : c;
          }).toList();
          _currentLevel = StepLevel.courriers;
        });
      }
    } catch (err) {
      debugPrint("Erreur lors de la clôture : $err");
    }
  }

  // --- ABONNEMENTS TEMPS RÉEL (MERCURE) ---

  void _subscribeToMercureEvents() {
    // 1. Topic Transfert / Nouveau message
    _messageSubscription = streamMercureTopic('message').listen((incomingData) {
      final MessageCourrier msg = incomingData;
      final bool estPourMoi = msg.destinataire.id == _currentUserId;

      if (estPourMoi) {
        setState(() {
          _nbNonTraite += 1;
          _courriers.insert(0, msg.courrier);
        });

        _showNotification(
          title: "📬 Nouveau message reçu - ${msg.courrier.object}",
          body: "De: ${msg.expediteur.nom}",
        );
      }

      final bool isViewingThisCourrier =
          (_currentLevel == StepLevel.messages || _currentLevel == StepLevel.detail) &&
          _selectedCourrier?.id == msg.courrier.id;

      if (isViewingThisCourrier) {
        setState(() {
          if (_selectedCourrier != null) {
            _selectedCourrier = _selectedCourrier!.copyWith(cloturePar: msg.courrier.cloturePar);
          }
          final exists = _messages.any((m) => m.id == msg.id);
          if (!exists) {
            _messages.insert(0, msg);
          }
        });
      }
    });

    // 2. Topic Lecture
    _lectureSubscription = streamMercureTopic('lectureMessage').listen((data) {
      final int msgId = data['id'];
      final String? isReadAt = data['isReadAt'];
      final int numExp = data['numeroExpediteur'];
      final int numDest = data['numeroDestinataire'];
      final int courrierId = data['courrier']['id'];

      setState(() {
        _courriers = _courriers.map((c) {
          return c.id == data['courrier']['messageId']
              ? c.copyWith(isReadAt: isReadAt, numero: numDest, numRef: numExp)
              : c;
        }).toList();

        _messages = _messages.map((m) {
          return m.id == msgId
              ? m.copyWith(isReadAt: isReadAt, numeroExpediteur: numExp, numeroDestinataire: numDest)
              : m;
        }).toList();

        if (_currentLevel == StepLevel.messages && _selectedCourrier?.id == courrierId) {
          _selectedCourrier = _selectedCourrier!.copyWith(
            isReadAt: isReadAt,
            numero: numDest,
            numRef: numExp,
          );
        }

        if (_currentLevel == StepLevel.detail && _selectedMessage?.id == msgId) {
          _selectedMessage = _selectedMessage!.copyWith(
            isReadAt: isReadAt,
            numeroExpediteur: numExp,
            numeroDestinataire: numDest,
          );
        }
      });
    });

    // 3. Topic Clôture
    _clotureSubscription = streamMercureTopic('clotureCourrier').listen((data) {
      final int id = data['id'];
      final Utilisateur? cloturePar = data['cloturePar'];

      setState(() {
        _courriers = _courriers.map((c) {
          return c.id == id ? c.copyWith(cloturePar: cloturePar) : c;
        }).toList();

        if (_selectedCourrier?.id == id) {
          _selectedCourrier = _selectedCourrier!.copyWith(cloturePar: cloturePar);
        }
      });
    });
  }

  // --- RENDU UI ---

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Récupération de l'ID chargé ou repli sur celui passé en paramètre
    
    return PopScope(
      canPop: _currentLevel == StepLevel.courriers,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentLevel == StepLevel.detail) {
          setState(() => _currentLevel = StepLevel.messages);
        } else if (_currentLevel == StepLevel.messages) {
          setState(() => _currentLevel = StepLevel.courriers);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildCurrentLevelView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelView() {
    switch (_currentLevel) {
      case StepLevel.courriers:
        return _buildCourrierListSection();
      case StepLevel.messages:
        return _buildMessageListSection();
      case StepLevel.detail:
        return _buildMessageDetailSection();
    }
  }

  // --- VUE 1 : NIVEAU COURRIERS ---
  Widget _buildCourrierListSection() {
    return Column(
      key: const ValueKey('courriers_view'),
      children: [
        Expanded(
          child: CourrierListView(
            courriers: _courriers,
            loading: _loading && _courriers.isEmpty,
            error: _error,
            nbNonTraite: _nbNonTraite,
            isTraiterAt: _isTraiterAt,
            onSelect: (courrier) {
              setState(() {
                _selectedCourrier = courrier;
                _currentLevel = StepLevel.messages;
              });
              _initMessages(courrier.id?? 0 );
            },
            // onFilterChange: (val) {
            //   setState(() => _isTraiterAt = val);
            //   _initCourriers();
            // },
          ),
        ),
        if (_hasMoreCourriers && _courriers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              onPressed: _loading ? null : _loadMoreCourriers,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Afficher plus de courriers"),
            ),
          ),
      ],
    );
  }

  // --- VUE 2 : NIVEAU MESSAGES ---
  Widget _buildMessageListSection() {
    if (_selectedCourrier == null) return const SizedBox.shrink();

    return Column(
      key: const ValueKey('messages_view'),
      children: [
        Expanded(
          child: MessageListView(
            courrier: _selectedCourrier!,
            messages: _messages,
            loading: _loading && _messages.isEmpty,
            error: _error,
            currentUserId: _currentUserId.toString(),
            isRecherche: widget.isRecherche,
            onBack: () => setState(() => _currentLevel = StepLevel.courriers),
            onSelect: (msg) {
              setState(() {
                _selectedMessage = msg;
                _currentLevel = StepLevel.detail;
              });
            },
            updateHistorique: _updateHistorique,
          ),
        ),
        if (_hasMoreMessages && _messages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton(
              onPressed: _loading ? null : _loadMoreMessages,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Charger les messages précédents"),
            ),
          ),
      ],
    );
  }

  // --- VUE 3 : NIVEAU DETAIL ---
  Widget _buildMessageDetailSection() {
    if (_selectedCourrier == null || _selectedMessage == null) {
      return const SizedBox.shrink();
    }

    return Center(
      key: const ValueKey('detail_view'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: MessageDetailView(
          courrier: _selectedCourrier!,
          message: _selectedMessage!,
          messages: _messages,
          currentUserId: _currentUserId.toString(),
          onBack: () => setState(() => _currentLevel = StepLevel.messages),
          onMessageRead: _handleMessageRead,
          onCloture: _handleLocalCloturation,
        ),
      ),
    );
  }

  // --- PLACEHOLDERS D'API & NOTIFICATIONS (À relier à tes services) ---

  Future<List<Courrier>> fetchCourriersByUser({String? lastDate, bool? isTraiterAt}) async {
    // Appelle ton repository / API Flutter ici
    List<Courrier> courriers = [];
    courriers = await CourrierService().getCourriersByUser(dateCursor: lastDate, isTraiterAt: isTraiterAt);
    return courriers;
  }

  Future<List<MessageCourrier>> fetchMessages({required int courrierId, String? lastDate}) async {
    List<MessageCourrier> messages = [];
    messages = await CourrierService().getMessagesByCourrier(courrierId, dateCursor: lastDate);
    return messages;
  }

  Future<int> getNbNonTraite() async => 0;

  Future<Map<String, dynamic>> cloturerCourrierApi(int id) async {
    return {'success': true, 'cloturePar': Utilisateur.fromId(id: _currentUserId)};
  }

  Stream<dynamic> streamMercureTopic(String topic) {
    // Relie ici ton client WebSockets ou Server-Sent Events (ex: via package 'flutter_client_sse')
    return const Stream.empty();
  }

  void _showNotification({required String title, required String body}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title\n$body"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


