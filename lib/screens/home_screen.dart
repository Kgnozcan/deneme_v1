import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Cyberpunk hissiyatı için siyah arka plan
      body: Stack(
        children: [
          // Neon Yağmur Efekti GIF
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/neon_rain.gif',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              SizedBox(height: 60),
              // Profil Kartı
              _buildProfileCard(),
              SizedBox(height: 40),
              // Oda Oluştur ve Katıl Butonları
              _buildActionButtons(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/avatars/cyber_wolf.png'), // Cyberpunk tarzı hayvan avatarı
          ),
          SizedBox(width: 16),
          // Kullanıcı Bilgileri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Oyuncu Adı", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Lig: Altın", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 16)),
              Text("Puan: 1200", style: GoogleFonts.orbitron(color: Colors.yellowAccent, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildCyberButton(context, "Oda Oluştur", Colors.pinkAccent, () {
          Navigator.pushNamed(context, '/createRoom');
        }),
        SizedBox(height: 20),
        _buildCyberButton(context, "Odaya Katıl", Colors.blueAccent, () {
          Navigator.pushNamed(context, '/joinRoom');
        }),
      ],
    );
  }

  Widget _buildCyberButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
        shadowColor: color.withOpacity(0.7),
        elevation: 12,
      ),
      child: Text(text, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
