import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'edit_property_screen.dart';
import 'booking_request_screen.dart';

const String baseUrl = 'http://10.0.2.2:3000';

class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? property;
  bool isLoading = true;
  bool isOwner = false;
  String? role;

  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final data = await apiService.getPropertyById(widget.propertyId);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      role = prefs.getString('role');

      setState(() {
        property = data;
        isOwner = data['ownerId'] == userId;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur de chargement")));
      Navigator.pop(context);
    }
  }

  Future<void> _deleteProperty() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Supprimer ce bien"),
        content: Text("Êtes-vous sûr de vouloir supprimer ce bien ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Supprimer")),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await apiService.deleteProperty(widget.propertyId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bien supprimé avec succès")));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _sendBookingRequest() async {
    if (_startDate == null || _endDate == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    try {
      await apiService.createBooking(
        property!['_id'],
        property!['title'],
        _messageController.text,
        property!['ownerId'],
        _startDate!,
        _endDate!,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Demande envoyée")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || property == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final images = property!['images'] ?? [];
    final features = property!['features'] ?? [];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.arrow_back, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  property!['title'] ?? 'Détail du bien',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (images.isNotEmpty)
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                final imageUrl = '$baseUrl${images[index]}';
                                return GestureDetector(
                                  onTap: () => _showFullImage(imageUrl),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 10),
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(imageUrl, fit: BoxFit.cover),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: Center(child: Icon(Icons.image_not_supported, size: 50)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(property!['title'] ?? 'Sans titre',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white70),
                                  SizedBox(width: 5),
                                  Text(property!['city'] ?? 'Non précisé',
                                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text("${property!['price'] ?? '0'} FCFA / mois",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                              SizedBox(height: 16),
                              Text(property!['description'] ?? 'Pas de description',
                                  style: TextStyle(color: Colors.white, fontSize: 16)),
                              SizedBox(height: 20),
                              if (features.isNotEmpty) ...[
                                Text("Équipements", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: List.generate(features.length, (index) {
                                    return Chip(
                                      label: Text(features[index]),
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      labelStyle: TextStyle(color: Colors.white),
                                    );
                                  }),
                                ),
                              ],
                              SizedBox(height: 20),
                              if (isOwner)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditPropertyScreen(property: property!),
                                          ),
                                        );
                                        if (result == true) _loadProperty();
                                      },
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      label: Text("Modifier", style: TextStyle(color: Colors.white)),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _deleteProperty,
                                      icon: Icon(Icons.delete),
                                      label: Text("Supprimer"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: isOwner
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  builder: (_) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      top: 20,
                      left: 16,
                      right: 16,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text("Réserver ce bien",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _messageController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Message au bailleur',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) setState(() => _startDate = picked);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFECEAFF),
                                    foregroundColor: Color(0xFF667eea),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(_startDate == null
                                      ? "Date de début"
                                      : "Début : ${_formatDate(_startDate)}"),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) setState(() => _endDate = picked);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFECEAFF),
                                    foregroundColor: Color(0xFF667eea),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(_endDate == null
                                      ? "Date de fin"
                                      : "Fin : ${_formatDate(_endDate)}"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);
                                await _sendBookingRequest();
                              },
                              icon: Icon(Icons.send),
                              label: Text("Envoyer la demande"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF667eea),
              icon: Icon(Icons.calendar_today),
              label: Text("Réserver"),
            ),
    );
  }
}
