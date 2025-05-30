import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const VibrantApp());
}

class VibrantApp extends StatelessWidget {
  const VibrantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrant Payment',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VibrantHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VibrantHomePage extends StatelessWidget {
  const VibrantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Calculate number of tiles per row based on screen width
    int crossAxisCount = 2;
    if (width > 700) {
      crossAxisCount = 4;
    } else if (width > 500) {
      crossAxisCount = 3;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Logo + PayLyt text Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(40, 40),
                      painter: PayLytLogoPainter(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "PayLyt",
                      style: GoogleFonts.righteous(
                        fontSize: 56,
                        color: Colors.cyanAccent,
                        letterSpacing: 2,
                        shadows: const [
                          Shadow(
                            blurRadius: 14.0,
                            color: Colors.blueAccent,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Welcome widget at bottom of title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Welcome",
                    style: GoogleFonts.dancingScript(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(
                    "Your ultimate digital companion for instant, secure, and vibrant money transfers.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  "Choose Payment Mode",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1,
                        children: [
                          _buildTwinkleTile(
                            title: 'To UPI ID',
                            icon: Icons.alternate_email,
                            color: Colors.cyan,
                            onTap: () {},
                          ),
                          _buildTwinkleTile(
                            title: 'To Mobile',
                            icon: Icons.phone_android,
                            color: Colors.pinkAccent,
                            onTap: () {},
                          ),
                          _buildTwinkleTile(
                            title: 'To Bank A/C',
                            icon: Icons.account_balance,
                            color: Colors.amber,
                            onTap: () {},
                          ),
                          _buildTwinkleTile(
                            title: 'Scan QR',
                            icon: Icons.qr_code_scanner,
                            color: Colors.greenAccent,
                            onTap: () {},
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 50),

                Text(
                  "Secure. Instant. Vibrant.",
                  style: GoogleFonts.robotoMono(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTwinkleTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: TwinkleGlowBox(
        color: color,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 56, color: Colors.white),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black45,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget that creates twinkling glow effect by animating a soft colored shadow flicker
class TwinkleGlowBox extends StatefulWidget {
  final Widget child;
  final Color color;

  const TwinkleGlowBox({Key? key, required this.child, required this.color})
    : super(key: key);

  @override
  State<TwinkleGlowBox> createState() => _TwinkleGlowBoxState();
}

class _TwinkleGlowBoxState extends State<TwinkleGlowBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        double glowStrength = _glowAnim.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.7 * glowStrength),
                blurRadius: 24 * glowStrength,
                spreadRadius: 8 * glowStrength,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.15 * glowStrength),
                blurRadius: 12 * glowStrength,
                spreadRadius: 3 * glowStrength,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Simple custom logo painter (replace with your own logo if you want)
class PayLytLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.cyanAccent, Colors.blueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw a stylized "P" shape logo as example
    path.moveTo(size.width * 0.2, size.height * 0.1);
    path.lineTo(size.width * 0.6, size.height * 0.1);
    path.arcToPoint(
      Offset(size.width * 0.6, size.height * 0.5),
      radius: Radius.circular(size.width * 0.3),
      clockwise: false,
    );
    path.lineTo(size.width * 0.2, size.height * 0.5);
    path.close();

    path.moveTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.9);
    path.lineTo(size.width * 0.2, size.height * 0.9);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
