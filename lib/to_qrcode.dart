import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ussd_launcher/ussd_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const VibrantQRPaymentApp());
}

class VibrantQRPaymentApp extends StatelessWidget {
  const VibrantQRPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrant QR Payment',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      home: const VibrantQRPaymentScreen(),
    );
  }
}

class VibrantQRPaymentScreen extends StatefulWidget {
  const VibrantQRPaymentScreen({super.key});

  @override
  State<VibrantQRPaymentScreen> createState() => _VibrantQRPaymentScreenState();
}

class _VibrantQRPaymentScreenState extends State<VibrantQRPaymentScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  bool isLoading = false;
  List<String> paymentMessages = [];
  int? selectedSimSlot;

  @override
  void initState() {
    super.initState();
    _loadSimCards();
    _requestCameraPermission();

    UssdLauncher.setUssdMessageListener((String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("USSD Response: $message")));
      setState(() {
        paymentMessages.add(message);
      });
    });
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) await Permission.camera.request();
  }

  Future<void> _loadSimCards() async {
    var status = await Permission.phone.status;
    if (!status.isGranted) await Permission.phone.request();

    final simCards = await UssdLauncher.getSimCards();
    setState(() {
      if (simCards.isNotEmpty) {
        selectedSimSlot = simCards[0]['slotIndex'];
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    controller!.scannedDataStream.listen((scanData) async {
      if (!scanned) {
        scanned = true;
        try {
          final data = scanData.code ?? '';

          // Parse UPI id and name from QR content like: upi://pay?pa=xxx@upi&pn=Name&...
          final queryString = data.split('?')[1];
          final params = Uri.splitQueryString(queryString);
          final upiId = params['pa'] ?? '';
          final name = params['pn'] ?? '';

          if (upiId.isEmpty) throw Exception('No UPI ID found');

          await controller?.pauseCamera();

          final details = await _showPaymentDetailsDialog(name, upiId);

          if (details != null) {
            await _startPayment(
              upiId,
              details['amount']!,
              details['remark']!,
              details['pin']!,
            );
          }

          scanned = false;
          await controller?.resumeCamera();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid QR code or error: $e")),
          );
          scanned = false;
          await controller?.resumeCamera();
        }
      }
    });
  }

  Future<Map<String, String>?> _showPaymentDetailsDialog(
    String name,
    String upiId,
  ) {
    final amountController = TextEditingController();
    final remarkController = TextEditingController();
    final pinController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Pay $name",
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "UPI ID:\n$upiId",
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildDialogTextField("Amount", amountController, isNumber: true),
              const SizedBox(height: 10),
              _buildDialogTextField("Remark", remarkController),
              const SizedBox(height: 10),
              _buildDialogTextField(
                "UPI PIN",
                pinController,
                isPassword: true,
                isNumber: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (amountController.text.isEmpty ||
                  remarkController.text.isEmpty ||
                  pinController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }
              Navigator.pop(context, {
                'amount': amountController.text.trim(),
                'remark': remarkController.text.trim(),
                'pin': pinController.text.trim(),
              });
            },
            child: const Text("Pay"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.lightBlueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _startPayment(
    String upi,
    String amount,
    String remark,
    String pin,
  ) async {
    setState(() {
      isLoading = true;
      paymentMessages.clear();
    });

    try {
      await UssdLauncher.multisessionUssd(
        code: "*99*1*3#",
        slotIndex: selectedSimSlot ?? 0,
        options: [upi, amount, remark, pin],
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction initiated")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay via QR Scan"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.cyanAccent,
              borderRadius: 20,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (paymentMessages.isNotEmpty) ...[
                    const Text(
                      "USSD Responses:",
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        children: paymentMessages
                            .map(
                              (msg) => Text(
                                msg,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  const Text(
                    "Scan the UPI QR code to pay.",
                    style: TextStyle(
                      color: Colors.white54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
