import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_repository.dart';
import '../utils/theme.dart';

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
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _auth.getMe();

    _name.text = (user['name'] ?? '').toString();

    setState(() {
      loading = false;
    });
  }

  // ---- PICK IMAGE ----
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => _imageFile = File(file.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => saving = true);

    String? avatarUrl;

    // ---- Upload image if changed ----
    if (_imageFile != null) {
      avatarUrl = await _auth.uploadAvatar(_imageFile!);
    }

    // ---- Update profile name ----
    await _auth.updateProfile(
      name: _name.text.trim(),
      avatar: avatarUrl,
    );

    // ---- Update password if filled ----
    if (_oldPassword.text.isNotEmpty && _newPassword.text.isNotEmpty) {
      await _auth.changePassword(
        oldPassword: _oldPassword.text,
        newPassword: _newPassword.text,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: AppTheme.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              width: double.infinity,
              decoration: AppTheme.mainGradient,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ---- AVATAR ----
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : const AssetImage("images/logo.png")
                                as ImageProvider,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 16, color: AppTheme.darkBlue),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ---- NAME ----
                    TextField(
                      controller: _name,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nom",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- EMAIL (READ ONLY) ----
                    FutureBuilder(
                      future: _auth.getMe(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }

                        return TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: ((snapshot.data as Map<String, dynamic>)['email'] ?? '').toString(),
                            labelStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // ---- PASSWORD SECTION ----
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Modifier le mot de passe",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _oldPassword,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Ancien mot de passe",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: _newPassword,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Nouveau mot de passe",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ---- SAVE BUTTON ----
                    AppTheme.gradientButton(
                      text: saving ? "Enregistrement..." : "Enregistrer",
                      onPressed: saving ? null : _saveProfile,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}


