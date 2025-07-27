import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFEE3BC), // Light beige
                  Color(0xFFFFF9F0), // Off-white
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD88C9A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(delay: 200.ms, duration: 1000.ms),
                ),
                Positioned(
                  bottom: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(delay: 300.ms, duration: 1000.ms),
                ),
              ],
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with Back button and title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF5E3023),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'My Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5E3023),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFF5E3023),
                        onPressed: () {
                          // Edit profile logic
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Profile avatar
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF5E3023),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Card for Personal Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5E3023),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Name',
                        style: TextStyle(color: Color(0xFF5E3023)),
                      ),
                      Text(
                        'mariem souadi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5E3023),
                        ),
                      ),
                      Divider(),
                      Text(
                        'Email',
                        style: TextStyle(color: Color(0xFF5E3023)),
                      ),
                      Text(
                        'souadimariem74@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5E3023),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Delete account button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Delete account logic
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}