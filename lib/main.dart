import 'package:app2/pages/to_mobile.dart';
import 'package:app2/pages/to_upi_id.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:app2/pages/qr_scan.dart';
import 'package:app2/pages/to_bank_acc.dart';

void main() {
  runApp(PaylytApp());
}

class PaylytApp extends StatelessWidget {
  const PaylytApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paylyt App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      // Start with the SplashScreen widget
      home: SplashScreen(),
    );
  }
}

// Splash Screen that shows the app icon full-screen for 3 seconds
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds then navigate to the HomeScreen
    Timer(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Full screen splash screen
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color:
            Colors
                .white, // You may set the background color or a gradient here.
        child: Center(
          // Display your app icon (ensure this asset exists and is declared in pubspec.yaml)
          child: Image.asset("assets/icon.png", width: 150, height: 150),
        ),
      ),
    );
  }
}

// The main HomeScreen widget with every feature we built (Connectivity, Sidebar, Welcome, Balance, Payment Options, etc.)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // Bottom navigation index
  int _selectedIndex = 0;
  // Dark mode toggle
  bool isDarkMode = false;
  // Scaffold key (for opening the drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Connectivity fields
  String connectionStatus = "Checking...";
  Color statusColor = Colors.grey;
  IconData connectionIcon = Icons.wifi_off;
  StreamSubscription<ConnectivityResult>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    checkConnectionStatus();
    // Listen to connectivity changes for instant update
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      updateConnectionStatus(result);
    });
  }

  // Initial connectivity check
  void checkConnectionStatus() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    updateConnectionStatus(connectivityResult);
  }

  // Updates the connection status values accordingly
  void updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        connectionStatus = "Online";
        statusColor = Colors.green;
        connectionIcon = Icons.wifi;
      } else {
        connectionStatus = "Offline";
        statusColor = Colors.red;
        connectionIcon = Icons.wifi_off;
      }
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  // Handle bottom navigation bar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Main scaffold with AppBar, Drawer, Body and BottomNavigationBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Pay Lyt',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundImage: AssetImage("assets/tony.jpeg"),
            radius: 15,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        // In the AppBar actions, add a small live data icon and a dark mode toggle.
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              connectionIcon,
              color: Colors.white,
              size: 20, // Small data icon
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('No Notifications!')));
            },
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildConnectionStatusBar(),
              SizedBox(height: 10),
              _buildWelcomeSection(),
              SizedBox(height: 20),
              _buildBalanceCard(),
              SizedBox(height: 20),
              _buildPaymentOptionsGrid(),
              SizedBox(height: 20),
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.deepPurple),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, color: Colors.deepPurple),
            label: 'Scan QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.deepPurple),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaytmQRScanner()),
            );
          } else {
            _onItemTapped(index);
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Widget: Connection Status Bar (shows the current online/offline status with a small icon)
  Widget _buildConnectionStatusBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            connectionStatus,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Icon(connectionIcon, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  // Widget: Sidebar (Drawer) with user profile and menu items
  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Master"),
            accountEmail: Text("@master123"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage("assets/tony.jpeg"),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Widget: Welcome Section (vibrant, stylish introduction)
  Widget _buildWelcomeSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Welcome to Paylyt!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your ultimate payment companion for fast, secure, and effortless transactions.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget: Balance Card (shows the current balance)
  Widget _buildBalanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 2),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Your Balance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '₹ 5,000.00',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Payment Options Grid (four options provided in a grid)
  Widget _buildPaymentOptionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildPaymentOption(
          Icons.qr_code_scanner,
          "Scan QR",
          Colors.orangeAccent,
          onTap: () {
            // Example: Navigate to QR Scan page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaytmQRScanner()),
            );
          },
        ),
        _buildPaymentOption(
          Icons.account_balance_wallet,
          "To UPI ID",
          Colors.greenAccent,
          onTap: () {
            // Example: Show a dialog or navigate
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UPIidPay()),
            );
          },
        ),
        _buildPaymentOption(
          Icons.phone_android,
          "To Mobile",
          Colors.blueAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UPImobilePay()),
            );
          },
        ),
        _buildPaymentOption(
          Icons.account_balance,
          "To Bank A/c",
          Colors.pinkAccent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BankPaymentApp()),
            );
          },
        ),
      ],
    );
  }

  // Widget: Individual Payment Option (icon + label inside a styled container)
  Widget _buildPaymentOption(
    IconData icon,
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color,
              child: Icon(icon, size: 45, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: Transaction History Section (lists recent transactions)
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        SizedBox(height: 10),
        _buildTransactionTile(
          "Netflix Subscription",
          "- ₹499",
          Icons.video_library,
        ),
        _buildTransactionTile(
          "Amazon Purchase",
          "- ₹2,000",
          Icons.shopping_cart,
        ),
        _buildTransactionTile(
          "Salary Received",
          "+ ₹50,000",
          Icons.monetization_on,
        ),
      ],
    );
  }

  // Widget: Individual Transaction Tile
  Widget _buildTransactionTile(String title, String amount, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Completed", style: TextStyle(color: Colors.green)),
        trailing: Text(
          amount,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
