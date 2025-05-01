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
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.deepPurple,
                ),
                label: const Text(
                  'Scan Again',
                  style: TextStyle(fontSize: 16, color: Colors.deepPurple),
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
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: EdgeInsets.all(10), // Ensures full-screen fit
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95, // Fits screen width
          height:
              MediaQuery.of(context).size.height * 0.85, // Fits screen height
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, color: Colors.indigo, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Enter Payment Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.indigo, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Recipient: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.cyan,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'UPI ID: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              upiId,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    hintText: '₹ 1000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                      color: Colors.indigo,
                    ),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        'Proceed to Pay',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      onPressed: () {
                        openUPIPayment(upiId, amountController.text);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
