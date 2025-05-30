import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_launcher/ussd_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ToMobile());
}

class ToMobile extends StatelessWidget {
  const ToMobile({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay to Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MobilePaymentScreen(),
    );
  }
}

class MobilePaymentScreen extends StatefulWidget {
  const MobilePaymentScreen({super.key});
  @override
  State<MobilePaymentScreen> createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  final mobileController = TextEditingController();
  final amountController = TextEditingController();
  final remarkController = TextEditingController();
  final upiPinController = TextEditingController();

  bool isLoading = false;
  List<String> paymentMessages = [];
  int? selectedSimSlot;

  @override
  void initState() {
    super.initState();
    _loadSimCards();
    _showAccessibilityPopup();
    UssdLauncher.setUssdMessageListener((String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("USSD Response: $message")));
      setState(() {
        paymentMessages.add(message);
      });
    });
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

  void _showAccessibilityPopup() {
    Future.delayed(const Duration(milliseconds: 700), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enable Accessibility Mode"),
          content: const Text(
            "To complete transactions:\n\n"
            "1. Open Settings\n"
            "2. Go to Accessibility\n"
            "3. Tap Installed Services\n"
            "4. Enable Offline Payment App",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _redirectToAccessibilitySettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    });
  }

  void _redirectToAccessibilitySettings() {
    final intent = AndroidIntent(
      action: 'android.settings.ACCESSIBILITY_SETTINGS',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    intent.launch();
  }

  void _startPayment() async {
    final mobile = mobileController.text.trim();
    final amount = amountController.text;
    final remark = remarkController.text;
    final pin = upiPinController.text;

    if ([mobile, amount, remark, pin].any((e) => e.isEmpty)) {
      _showError("Please fill all fields.");
      return;
    }

    if (!RegExp(r"^[6-9]\d{9}$").hasMatch(mobile)) {
      _showError("Enter a valid 10-digit mobile number.");
      return;
    }

    setState(() {
      isLoading = true;
      paymentMessages.clear();
    });

    try {
      await UssdLauncher.multisessionUssd(
        code: "*99*1*1#", // Adjust code as needed for mobile-based transfers
        slotIndex: selectedSimSlot ?? 0,
        options: [mobile, amount, remark, pin],
      );
      _showSuccess("Transaction initiated");
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
        mobileController.clear();
        amountController.clear();
        remarkController.clear();
        upiPinController.clear();
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white10, Colors.white24],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.black, Colors.purple],
            center: Alignment.topRight,
            radius: 1.3,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.phone_iphone,
                          size: 50,
                          color: Colors.pinkAccent,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "📱 Pay to Mobile Number",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          "Mobile Number",
                          mobileController,
                          Icons.phone,
                          isNumber: true,
                        ),
                        _buildTextField(
                          "Amount",
                          amountController,
                          Icons.currency_rupee,
                          isNumber: true,
                        ),
                        _buildTextField(
                          "Remark",
                          remarkController,
                          Icons.message,
                        ),
                        _buildTextField(
                          "UPI PIN",
                          upiPinController,
                          Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: isLoading ? null : _startPayment,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 60,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.pinkAccent,
                                  Colors.orangeAccent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pinkAccent.withOpacity(0.5),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                : const Text(
                                    "Send Payment",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (paymentMessages.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Responses:",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...paymentMessages.map(
                                (msg) => Text(
                                  msg,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
