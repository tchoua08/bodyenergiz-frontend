import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_repository.dart';
import '../utils/theme.dart';
import 'profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthRepository _auth = AuthRepository();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();

  File? _imageFile;
  bool loading = false;

  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final res = await _auth.getMe();
    if (res["ok"]) {
      setState(() {
        user = res["data"];
        _name.text = user?["name"] ?? "";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => loading = true);

    String? avatarUrl;

    // -------------------------
    // Upload avatar si présent
    // -------------------------
    if (_imageFile != null) {
      final res = await _auth.uploadAvatar(_imageFile!.path);

      if (res["ok"]) {
        avatarUrl = res["data"]["photoUrl"];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur upload avatar : ${res["error"]}")),
        );
      }
    }

    // -------------------------
    // Update profile (name + avatar)
    // -------------------------
    final updateRes = await _auth.updateProfile(
      name: _name.text,
      photoUrl: avatarUrl,
    );

    if (!updateRes["ok"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur maj profil : ${updateRes["error"]}")),
      );
      setState(() => loading = false);
      return;
    }

    // -------------------------
    // Change password si rempli
    // -------------------------
    if (_oldPassword.text.isNotEmpty && _newPassword.text.isNotEmpty) {
      final passRes = await _auth.changePassword(
        _oldPassword.text,
        _newPassword.text,
      );

      if (!passRes["ok"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur changement mdp : ${passRes["error"]}")),
        );
      }
    }

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour avec succès !")),
    );

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------------
      // APPBAR AVEC RETOUR
      // --------------------------
      appBar: AppBar(
        title: const Text("Modifier mon profil"),
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ),

      // --------------------------
      // MAIN CONTENT
      // --------------------------
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --------------------------
              // AVATAR
              // --------------------------
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(.2),
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (user?["photoUrl"] != null
                          ? NetworkImage(user!["photoUrl"])
                          : const AssetImage("images/logo.png")) as ImageProvider,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --------------------------
              // NAME FIELD
              // --------------------------
              TextField(
                controller: _name,
                style: const TextStyle(color: Colors.white),
                decoration: _input("Nom complet"),
              ),

              const SizedBox(height: 20),

              // --------------------------
              // PASSWORD CHANGE FIELDS
              // --------------------------
              TextField(
                controller: _oldPassword,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _input("Ancien mot de passe"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _newPassword,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _input("Nouveau mot de passe"),
              ),

              const SizedBox(height: 30),

              // --------------------------
              // SAVE BUTTON
              // --------------------------
              AppTheme.gradientButton(
                text: loading ? "Patiente..." : "Enregistrer",
                onPressed: loading ? null : _saveChanges,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white38),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}


