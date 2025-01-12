import 'package:e_shop_igl/screens/DetailsPage.dart';
import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> devices = [];
  List<Map<String, dynamic>> filteredDevices = [];
  bool isLoading = true;
  String searchQuery = '';
  List<String> categories = [
    'All',
    'Clavier',
    'Souris',
    'PC',
    'Camera',
    'Desktop'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  // Fetch devices from the database
  Future<void> _fetchDevices() async {
    try {
      final response =
          await supabase.from('devices').select().order('created_at');
      setState(() {
        devices = List<Map<String, dynamic>>.from(response);
        filteredDevices = devices;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load devices: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Filter devices based on the search query
  void _filterDevices() {
    setState(() {
      filteredDevices = devices
          .where((device) =>
              device['name'].toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  // Filter devices by category
  void _filterByCategory(String category) {
    if (category == 'All') {
      setState(() {
        filteredDevices = devices; // Show all devices
      });
    } else {
      setState(() {
        filteredDevices = devices
            .where((device) =>
                device['type']?.toLowerCase() == category.toLowerCase())
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Devices Dashboard'),
        backgroundColor: CustomColors.lightCream,
      ),
      body: Column(
        children: [
          // Categories Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        _filterByCategory(category);
                      },
                      child: Text(category),
                      style: ElevatedButton.styleFrom(
                        iconColor: CustomColors.lightCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _filterDevices();
              },
            ),
          ),
          // Loading or displaying devices
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredDevices.isEmpty
                    ? Center(
                        child: Text(
                          'No devices available.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 6 / 7,
                        ),
                        itemCount: filteredDevices.length,
                        itemBuilder: (context, index) {
                          final device = filteredDevices[index];
                          return _buildDeviceCard(device);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Function to build a single device card
  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Device Image
          Expanded(
            child: device['image_url'] != null
                ? Image.network(
                    device['image_url'], // Display device image
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.device_unknown,
                      size: 40,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
          // Device Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Type: ${device['type'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Status: ${device['status'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: device['status'] == 'active'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: ${device['quantity'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Price: ${device['price'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Add button at the bottom of the card
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the DeviceDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailsPage(device: device),
                  ),
                );
              },
              child: Text('Show Details'),
              style: ElevatedButton.styleFrom(
                iconColor: CustomColors.lightCream, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
