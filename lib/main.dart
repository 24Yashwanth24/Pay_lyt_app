import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom AppBar Example')),
      body: const Center(
        child: Text('Welcome to Home Screen', style: TextStyle(fontSize: 20)),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 42),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Already on Home Screen!')),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.qr_code_2_outlined,
                color: Colors.blueAccent,
                size: 50,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaytmQRScanner(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 42),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaytmQRScanner extends StatefulWidget {
  const PaytmQRScanner({super.key});

  @override
  PaytmQRScannerState createState() => PaytmQRScannerState();
}

class PaytmQRScannerState extends State<PaytmQRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        String data = scanData.code ?? '';
        String upiId = Uri.decodeComponent(
          data.split('?')[1].split('&')[0].split('=')[1],
        );
        String name = Uri.decodeComponent(
          data.split('?')[1].split('&')[1].split('=')[1],
        );
        showPaymentAmountDialog(context, name, upiId);
      });
    });
  }
}

void showPaymentAmountDialog(BuildContext context, String name, String upiId) {
  TextEditingController amountController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Payment Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Recipient Name: $name'),
            Text('UPI ID: $upiId'),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Payment Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Pay'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CreateOrderScreen(
                        upiiId: upiId,
                        amt: int.parse(amountController.text),
                      ),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text('Not yet developed')));
  }
}

class CreateOrderScreen extends StatefulWidget {
  final String upiiId;
  final int amt;

  const CreateOrderScreen({super.key, required this.upiiId, required this.amt});

  @override
  CreateOrderScreenState createState() => CreateOrderScreenState();
}

class CreateOrderScreenState extends State<CreateOrderScreen> {
  String apiKey = 'rzp_test_ljQGK7H0xU7VE2'; // Replace with Razorpay API Key
  String apiSecret =
      '9iMvSRwphyoPFABu8P7BH58n'; // Replace with Razorpay API Secret
  String url = 'https://api.razorpay.com/v1/orders';

  String orderResponseBody = '';

  Future<void> createOrder() async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

    final Map<String, dynamic> orderData = {
      "amount": widget.amt * 100, // Amount in paise
      "currency": "INR",
      "receipt": "receipt#123",
      "payment_capture": 1,
      "notes": {"upi_id": widget.upiiId},
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      );
      setState(() {
        orderResponseBody = response.body; // Log the response body
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order Created Successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to Create Order')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('An error occurred!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Razorpay Order')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: createOrder,
              child: const Text('Create Order'),
            ),
            const SizedBox(height: 20),
            Text(orderResponseBody), // Display the response body here
          ],
        ),
      ),
    );
  }
}
