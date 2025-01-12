import 'package:flutter/material.dart';

List<Map<String, dynamic>> cartItems = []; // Global cart list

class DeviceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> device;

  DeviceDetailsPage({required this.device});

  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
  bool isFavorite = false;

  void _addToCart() {
    setState(() {
      cartItems.add(widget.device);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.device['name']} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.device['name'] ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            widget.device['image_url'] != null
                ? Image.network(widget.device['image_url'])
                : Container(
                    color: Colors.grey[300],
                    height: 200,
                    child: Icon(
                      Icons.device_unknown,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
            SizedBox(height: 16),
            Text('Type: ${widget.device['type'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Status: ${widget.device['status'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Quantity: ${widget.device['quantity'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text('Price: ${widget.device['price'] ?? 'N/A'}'),
            SizedBox(height: 8),
            Text(
                'Details: ${widget.device['details'] ?? 'No details available'}'),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addToCart,
                  child: Text('Add to Cart'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFavorite
                            ? 'Added to Favorites'
                            : 'Removed from Favorites'),
                      ),
                    );
                  },
                  child: Text(isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
