import 'package:flutter/material.dart';
import 'package:ussd_launcher/ussd_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo),
      ),
      home: OfflinePaymentScreen(),
    );
  }
}

class OfflinePaymentScreen extends StatefulWidget {
  const OfflinePaymentScreen({super.key});

  @override
  _OfflinePaymentScreenState createState() => _OfflinePaymentScreenState();
}

class _OfflinePaymentScreenState extends State<OfflinePaymentScreen> {
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();
  final TextEditingController upiPinController = TextEditingController();

  List<String> paymentMessages = [];
  bool isLoading = false;
  int? selectedSimSlot;

  @override
  void initState() {
    super.initState();
    _loadSimCards();
    _showAccessibilityPopup();
    UssdLauncher.setUssdMessageListener((String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Message Received: $message")),
      );
      setState(() {
        paymentMessages.add(message);
      });
    });
  }

  Future<void> _loadSimCards() async {
    var status = await Permission.phone.status;
    if (status.isGranted) {
      final simCards = await UssdLauncher.getSimCards();
      setState(() {
        if (simCards.isNotEmpty) {
          selectedSimSlot = simCards[0]['slotIndex'];
        }
      });
    }
  }

  void _showAccessibilityPopup() {
    Future.delayed(Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Enable Accessibility Mode"),
          content: Text(
            "To complete transactions, enable Accessibility Mode:\n\n"
            "1. Open **Settings**\n2. Go to **Accessibility**\n3. Select **Installed Services**\n4. Enable **Offline Payment App**",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _redirectToAccessibilitySettings();
              },
              child: Text("OK"),
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

  void startPaymentTransaction() async {
    String upiID = upiIdController.text;
    String amount = amountController.text;
    String remark = remarkController.text;
    String upiPin = upiPinController.text;

    if (upiID.isEmpty || amount.isEmpty || remark.isEmpty || upiPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: All fields must be filled.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      paymentMessages.clear();
    });

    try {
      await UssdLauncher.multisessionUssd(
        code: "*99*1*3#",
        slotIndex: selectedSimSlot ?? 0,
        options: [upiID, amount, remark, upiPin],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment transaction started successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Transaction Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
        upiIdController.clear();
        amountController.clear();
        remarkController.clear();
        upiPinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Offline Payment App")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTextField(
                  upiIdController,
                  "UPI ID",
                  Icons.account_balance,
                ),
                _buildTextField(
                  amountController,
                  "Amount",
                  Icons.money,
                  isNumber: true,
                ),
                _buildTextField(remarkController, "Remark", Icons.comment),
                _buildTextField(
                  upiPinController,
                  "UPI PIN",
                  Icons.lock,
                  isPassword: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: startPaymentTransaction,
                  child: Text(
                    "Pay",
                    style: TextStyle(fontSize: 18, color: Colors.indigo),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Payment Responses:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueGrey[100],
                  ),
                  padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    child: Column(
                      children: paymentMessages.map((message) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            message,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
