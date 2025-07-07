import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({Key? key}) : super(key: key);

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final data = await apiService.getBookingsForOwner();
      setState(() {
        bookings = data;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    try {
      await apiService.updateBookingStatus(id, status);
      _fetchBookings(); // refresh
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur mise à jour")));
    }
  }

  Widget _buildBookingCard(dynamic booking) {
    final property = booking['propertyId'];
    final startDate =
        DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['startDate']));
    final endDate =
        DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['endDate']));

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🏠 ${property != null ? property['title'] ?? 'Bien inconnu' : 'Bien inconnu'}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("👤 Locataire : ${booking['renterName'] ?? 'Inconnu'}"),
            Text("📅 Du $startDate au $endDate"),
            Text("💬 Message : ${booking['message'] ?? ''}"),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Statut : ${booking['status']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (booking['status'] == 'pending')
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            _updateStatus(booking['_id'], 'accepted'),
                        child: Text("Accepter",
                            style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () =>
                            _updateStatus(booking['_id'], 'rejected'),
                        child: Text("Refuser",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demandes de réservation")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text("Aucune demande reçue."))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (ctx, index) =>
                      _buildBookingCard(bookings[index]),
                ),
    );
  }
}
