import 'package:flutter/material.dart';

List<Map<String, dynamic>> cartItems = []; // Global cart list

class DeviceDetailsPage extends StatefulWidget {
  final Map<String, dynamic> device;

  const DeviceDetailsPage({super.key, required this.device});

  @override
  _DeviceDetailsPageState createState() => _DeviceDetailsPageState();
}

class _DeviceDetailsPageState extends State<DeviceDetailsPage> {
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
      appBar: AppBar(title: Text('Device Details')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.device['image_url'] != null
                  ? Image.network(widget.device['image_url'], height: 200)
                  : Container(
                      color: Colors.grey[300],
                      height: 200,
                      width: 200,
                      child: Icon(Icons.device_unknown,
                          size: 80, color: Colors.grey[600]),
                    ),
              SizedBox(height: 16),
              Text(
                widget.device['name'] ?? 'N/A',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text('Type: ${widget.device['type'] ?? 'N/A'}'),
              Text('Status: ${widget.device['status'] ?? 'N/A'}'),
              Text('Price: ${widget.device['price'] ?? 'N/A'}'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Details: ${widget.device['details'] ?? 'No details available'}',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addToCart,
                child: Text('Add to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
