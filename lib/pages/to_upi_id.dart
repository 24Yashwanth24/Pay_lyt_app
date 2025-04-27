import 'package:flutter/material.dart';
import 'package:app2/pages/qr_scan.dart';
import 'package:app2/main.dart';

class UPIidPay extends StatelessWidget {
  const UPIidPay({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UPI Payment',
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.light(primary: Colors.deepPurple),
      ),
      home: UPIidPaymentScreen(),
    );
  }
}

class UPIidPaymentScreen extends StatefulWidget {
  const UPIidPaymentScreen({super.key});
  @override
  UPIidPaymentScreenState createState() => UPIidPaymentScreenState();
}

class UPIidPaymentScreenState extends State<UPIidPaymentScreen> {
  TextEditingController upiIdController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Send Money via UPI'),
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
                      controller: upiIdController,
                      decoration: InputDecoration(
                        labelText: 'Recipient UPI ID',
                        hintText: 'e.g., recipient@upi',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.deepPurple,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a UPI ID';
                        }
                        // Add more validation if needed
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
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
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        openUPIPayment(
                          upiIdController.text,
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
