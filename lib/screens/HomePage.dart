import 'package:e_shop_igl/screens/DetailsPage.dart';
import 'package:e_shop_igl/screens/FavPage.dart';
import 'package:e_shop_igl/ui/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

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
  Set<int> favoriteDeviceIds = {}; // Track favorite devices by their IDs

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _addToFavorites(Map<String, dynamic> device) async {
    try {
      final response = await supabase.from('favorites').insert({
        'device_id': device['id'], // Required: device ID
        'name': device['name'], // Add name
        'type': device['type'], // Add type
        'status': device['status'], // Add status
        'price': device['price'], // Add price
        'image_url': device['image_url'], // Add image_url
      });

      if (response.error == null) {
        setState(() {
          favoriteDeviceIds
              .add(device['id']); // Add the device ID to the favorites set
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${device['name']} added to favorites!')),
        );
      } else {
        throw response.error!.message;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to favorites: $e')),
      );
    }
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
      _fetchFavorites(); // Fetch existing favorites after loading devices
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load devices: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch favorite devices from the database to track which items are favorited
  Future<void> _fetchFavorites() async {
    try {
      final response = await supabase.from('favorites').select('device_id');
      setState(() {
        favoriteDeviceIds =
            Set<int>.from(response.map((item) => item['device_id'] as int));
      });
    } catch (e) {
      print('Error fetching favorites: $e');
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
                      style: ElevatedButton.styleFrom(
                        iconColor: CustomColors.lightCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(category),
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
    bool isFavorite = favoriteDeviceIds
        .contains(device['id']); // Check if device is already in favorites

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
          // Add button at the bottom of the card (only visible if not already in favorites)
          if (!isFavorite)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add device to favorites
                  _addToFavorites(device);
                },
                style: ElevatedButton.styleFrom(
                  iconColor: CustomColors.lightCream, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Add to Favourites'),
              ),
            ),
          // Show Details button (always visible)
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
              style: ElevatedButton.styleFrom(
                iconColor: CustomColors.lightCream, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Show Details'),
            ),
          ),
        ],
      ),
    );
  }
}
