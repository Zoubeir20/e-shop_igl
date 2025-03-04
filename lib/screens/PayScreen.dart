import 'package:e_shop_igl/screens/DetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({super.key});

  @override
  _PayScreenState createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _customerId;
  bool _isCardDetailsValid = false;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail(); // Fetch and populate the email on initialization
  }

  Future<void> _fetchUserEmail() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user != null) {
      setState(() {
        _emailController.text =
            user.email ?? ''; // Automatically populate the email
      });
    }
  }

  bool _validateCardDetails() {
    // Validate Card Number (Visa/MasterCard: 13-16 digits)
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cardNumber.length < 13 ||
        cardNumber.length > 16 ||
        !RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return false;
    }

    // Validate Expiry Date (MM/YY)
    final expiryDate = _expiryDateController.text;
    if (!expiryDate.contains('/') || expiryDate.length != 5) {
      return false;
    }

    final expiryParts = expiryDate.split('/');
    final expMonth = int.tryParse(expiryParts[0]);
    final expYear = int.tryParse('20' + expiryParts[1]);

    if (expMonth == null ||
        expMonth < 1 ||
        expMonth > 12 ||
        expYear == null ||
        expYear < DateTime.now().year) {
      return false;
    }

    // Validate CVV (3 or 4 digits)
    final cvv = _cvvController.text;
    if (cvv.length != 3 && cvv.length != 4 ||
        !RegExp(r'^[0-9]+$').hasMatch(cvv)) {
      return false;
    }

    return true;
  }

  Future<void> _savePaymentMethod() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/save-payment-method');

    try {
      final paymentMethodId = _generatePaymentMethodId();

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'paymentMethodId': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _customerId = data['customerId'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? '.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processAutoPayment(double amount) async {
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/auto-charge-customer');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': _customerId,
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': 'usd',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        // Clear the cart items after a successful payment
        setState(() {
          cartItems.clear(); // Clear the cart
        });
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to auto-charge customer.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment(double amount) async {
    if (_cardNumberController.text.isEmpty ||
        _expiryDateController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all card details')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://localhost:3000/process-payment');

    try {
      // Validate and split expiry date
      if (!_expiryDateController.text.contains('/')) {
        throw Exception("Invalid expiry date format. Use MM/YY.");
      }

      final expiryDate = _expiryDateController.text.split('/');
      if (expiryDate.length != 2) {
        throw Exception("Invalid expiry date format. Use MM/YY.");
      }

      final expMonth = int.tryParse(expiryDate[0]) ?? 0;
      final expYear = int.tryParse(expiryDate[1]) ?? 0;
      if (expMonth < 1 || expMonth > 12 || expYear < 0) {
        throw Exception("Invalid expiry date.");
      }

      // Call the backend endpoint
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cardNumber': _cardNumberController.text,
          'expMonth': expMonth,
          'expYear': expYear,
          'cvc': _cvvController.text,
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': 'usd',
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to process payment.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generatePaymentMethodId() {
    return 'pm_card_visa'; // Use Stripe's test card PaymentMethod ID
  }

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Cart',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                        setState(() {
                          cartItems.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${item['name']} removed from cart')),
                        );
                      },
                    ),
                  );
                },
              ),
              Divider(),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Prevent manual entry
              ),
              SizedBox(height: 16),
              TextField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _isCardDetailsValid = _validateCardDetails();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expiryDateController,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  setState(() {
                    _isCardDetailsValid = _validateCardDetails();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    _isCardDetailsValid = _validateCardDetails();
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isCardDetailsValid && !_isLoading
                    ? () async {
                        // First save the payment method
                        await _savePaymentMethod();

                        // Then process the auto payment if a payment method is saved
                        if (_customerId != null) {
                          await _processAutoPayment(totalPrice);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('')),
                          );
                        }
                      }
                    : null,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('PAY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
