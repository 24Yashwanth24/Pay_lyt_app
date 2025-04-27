import 'package:flutter/material.dart';
import 'package:app2/main.dart';
import 'package:url_launcher/url_launcher.dart';

class BankPaymentApp extends StatelessWidget {
  const BankPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bank Payment',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.light(primary: Colors.deepPurple),
      ),
      home: BankPaymentScreen(),
    );
  }
}

class BankPaymentScreen extends StatefulWidget {
  const BankPaymentScreen({super.key});
  @override
  BankPaymentScreenState createState() => BankPaymentScreenState();
}

class BankPaymentScreenState extends State<BankPaymentScreen> {
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController ifscCodeController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void openBankPayment(
    String accountNumber,
    String ifscCode,
    String amount,
  ) async {
    String bankPaymentUrl =
        "upi://pay?pa=$accountNumber@$ifscCode&pn=Recipient&am=$amount&cu=INR&tn=BankTransfer";

    if (await canLaunchUrl(Uri.parse(bankPaymentUrl))) {
      await launchUrl(Uri.parse(bankPaymentUrl));
    } else {
      throw "Could not launch UPI app";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Send Money via Bank Account'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: accountNumberController,
                      decoration: InputDecoration(
                        labelText: 'Recipient Account Number',
                        hintText: 'e.g., 123456789012',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.account_balance,
                          color: Colors.deepPurple,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length < 9) {
                          return 'Enter a valid account number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: ifscCodeController,
                      decoration: InputDecoration(
                        labelText: 'IFSC Code',
                        hintText: 'e.g., SBIN0001234',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.confirmation_number,
                          color: Colors.deepPurple,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 11) {
                          return 'Enter a valid 11-character IFSC code';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'Enter Amount',
                        hintText: '1000',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: Colors.deepPurple,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    child: Text(
                      'Pay',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        openBankPayment(
                          accountNumberController.text,
                          ifscCodeController.text,
                          amountController.text,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openBankPayment(
  String accountNumber,
  String ifscCode,
  String amount,
) async {
  String bankPaymentUrl =
      "upi://pay?pa=$accountNumber@ifscCode&pn=Recipient&am=$amount&cu=INR&tn=BankTransfer";

  if (await canLaunchUrl(Uri.parse(bankPaymentUrl))) {
    await launchUrl(Uri.parse(bankPaymentUrl));
  } else {
    throw "Could not launch UPI app";
  }
}
