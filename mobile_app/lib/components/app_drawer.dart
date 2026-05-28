import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';
import '../screens/assessment_form.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final user = FirebaseAuth.instance.currentUser;
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B0F1A),
      child: StreamBuilder<DocumentSnapshot>(
        stream: DBService().getUserData(),
        builder: (context, snapshot) {
          // Extract data safely
          String name = user?.displayName ?? "User";
          String email = user?.email ?? "No Email";
          
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? name;
            _currentRating = data['appRating'] ?? 0;
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              // 1. USER PROFILE HEADER
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                accountEmail: Text(email, style: const TextStyle(color: Colors.cyanAccent)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: const Color(0xFF06B6D4).withOpacity(0.2),
                  child: const Icon(Icons.person, size: 40, color: Colors.cyanAccent),
                ),
              ),

              const SizedBox(height: 20),

              // 2. HEALTH PARAMETERS SETTINGS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text("HEALTH DATA", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border, color: Colors.redAccent),
                title: const Text("Edit 11 Parameters", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Update BP, Cholesterol, etc.", style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                onTap: () {
                  // Close the drawer and open the Assessment Form
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AssessmentFormScreen()));
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(color: Colors.white10, height: 40),
              ),

              // 3. RATING SYSTEM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text("RATE PULSE EDGE", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _currentRating ? Icons.star : Icons.star_border,
                      color: index < _currentRating ? Colors.amber : Colors.white38,
                      size: 32,
                    ),
                    onPressed: () async {
                      // Instantly update UI and save to Firestore
                      setState(() => _currentRating = index + 1);
                      await DBService().saveRating(_currentRating);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Thanks for rating us!"), backgroundColor: Colors.green),
                        );
                      }
                    },
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}