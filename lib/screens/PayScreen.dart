import 'package:e_shop_igl/screens/DetailsPage.dart';
import 'package:flutter/material.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0,
      (sum, item) => sum + (item['price'] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Cart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    leading: item['image_url'] != null
                        ? Image.network(
                            item['image_url'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.device_unknown),
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text('\$${item['price'] ?? 0}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        cartItems.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${item['name']} removed from cart')),
                        );
                        (context as Element).reassemble();
                      },
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Total: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulate payment
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment Successful!')),
                );
                cartItems.clear(); // Clear cart after payment
                (context as Element).reassemble();
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
