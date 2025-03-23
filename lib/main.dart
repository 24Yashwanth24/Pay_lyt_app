import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PaytmQRScanner());
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
      appBar: AppBar(title: Text('Paytm QR Scanner')),
      body: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        // Handle scanned QR code data
        String data = scanData.code ?? '';
        // Parse Paytm QR code data
        String upiId = data.split('?')[1].split('&')[0].split('=')[1];
        String name = data.split('?')[1].split('&')[1].split('=')[1];
        // Prompt user to enter payment amount and display recipient information
        showPaymentAmountDialog(context, name, upiId);
      });
    });
  }
}

void showPaymentAmountDialog(BuildContext context, String name, String upiId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Enter Payment Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Recipient Name: $name'),
            Text('UPI ID: $upiId'),
            TextField(
              decoration: InputDecoration(labelText: 'Payment Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Pay'),
            onPressed: () {
              // Handle payment logic
            },
          ),
        ],
      );
    },
  );
}
