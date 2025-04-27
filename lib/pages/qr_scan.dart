import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  128,
                  128,
                  128,
                  0.3,
                ), // RGB with alpha (opacity)
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Place QR Code within the frame',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  'Scan Again',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () => controller?.resumeCamera(),
              ),
            ],
          ),
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

void openUPIPayment(String upiId, String amount) async {
  String upiUrl =
      "upi://pay?pa=$upiId&pn=Recipient&am=$amount&cu=INR&tn=Payment";

  if (await canLaunchUrl(Uri.parse(upiUrl))) {
    await launchUrl(Uri.parse(upiUrl));
  } else {
    throw "Could not launch UPI app";
  }
}

void showPaymentAmountDialog(BuildContext context, String name, String upiId) {
  TextEditingController amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payment, color: Colors.white, size: 26),
              SizedBox(width: 10),
              Text(
                'Enter Payment Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.deepPurple, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Recipient: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(name, style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'UPI ID: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(upiId, style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  hintText: '₹ 1000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                    color: Colors.deepPurple,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  'Proceed to Pay',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            onPressed: () {
              openUPIPayment(upiId, amountController.text);
            },
          ),
        ],
      );
    },
  );
}
