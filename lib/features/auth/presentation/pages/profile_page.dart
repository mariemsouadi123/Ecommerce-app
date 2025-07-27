import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE5B4), // Light peach
              Color(0xFFFFDAB9), // Slightly darker peach
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back button and title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit, color: Colors.brown),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile avatar
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.brown,
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
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
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
                        color: Colors.brown,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Name',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'mariem souadi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
                      ),
                    ),
                    Divider(),
                    Text(
                      'Email',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'souadimariem74@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
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
                    // Add your delete logic here
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
      ),
    );
  }
}
