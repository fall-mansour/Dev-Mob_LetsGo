import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // AJOUT IMPORT HTTP
import 'dart:convert'; // AJOUT IMPORT CONVERT POUR LE JSON

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // FONCTION DE CONNEXION RÉELLE AU BACKEND
  Future<void> _soumettreInscription() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // RÈGLE DE L'IP : 10.0.2.2 si émulateur Android, localhost si simulateur iOS
      // Remplace par l'IP de ton Mac (ex: 192.168.x.x) si tu testes sur un vrai téléphone
      // Remplace temporairement ta variable urlApi par celle-ci pour tes tests sur Firefox :
      const String urlApi = "http://localhost:3000/api/compte/register";

      try {
        final response = await http.post(
          Uri.parse(urlApi),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "nom": _nomController.text.trim(),
            "prenom": _prenomController.text.trim(),
            "telephone": _phoneController.text
                .trim(), // Clé calée sur le backend
            "email": _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            "mot_de_passe":
                _passwordController.text, // Clé calée sur le backend
            "adresse": _adresseController.text.trim().isEmpty
                ? null
                : _adresseController.text.trim(),
          }),
        );

        final data = jsonDecode(response.body);

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          // SUCCÈS : L'utilisateur est en base de données !
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Compte créé avec succès ! Connectez-vous."),
              backgroundColor: Color(0xFF7B61FF),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context); // Retour à la page de connexion
        } else {
          // ERREUR RETOURNÉE PAR LE SERVEUR (ex: Numéro déjà existant)
          _afficherErreur(data['message'] ?? "Une erreur est survenue.");
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // ERREUR DE CONNEXION (Le serveur Node.js est éteint ou mauvaise IP)
        _afficherErreur(
          "Impossible de joindre le serveur. Vérifie ta connexion Node.js.",
        );
      }
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Créer un compte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Rejoignez LetsGo pour vous déplacer facilement.",
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
                const SizedBox(height: 30),

                _buildLabel("PRÉNOM *"),
                _buildTextField(
                  controller: _prenomController,
                  hint: "Ex: Amadou",
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v!.trim().isEmpty ? "Le prénom est requis" : null,
                ),
                const SizedBox(height: 20),

                _buildLabel("NOM *"),
                _buildTextField(
                  controller: _nomController,
                  hint: "Ex: Konaté",
                  icon: Icons.badge_outlined,
                  validator: (v) =>
                      v!.trim().isEmpty ? "Le nom est requis" : null,
                ),
                const SizedBox(height: 20),

                _buildLabel("NUMÉRO DE TÉLÉPHONE *"),
                _buildTextField(
                  controller: _phoneController,
                  hint: "Ex: 771234567",
                  icon: Icons.phone_android,
                  type: TextInputType.phone,
                  validator: (v) =>
                      v!.trim().isEmpty ? "Le numéro est requis" : null,
                ),
                const SizedBox(height: 20),

                _buildLabel("ADRESSE HABITUELLE"),
                _buildTextField(
                  controller: _adresseController,
                  hint: "Ex: Grand Médine, Dakar",
                  icon: Icons.home_outlined,
                  validator: (v) => null,
                ),
                const SizedBox(height: 20),

                _buildLabel("ADRESSE EMAIL (OPTIONNEL)"),
                _buildTextField(
                  controller: _emailController,
                  hint: "Ex: amadou@email.com",
                  icon: Icons.mail_outline,
                  type: TextInputType.emailAddress,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !v.contains('@')) {
                      return "Format d'email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel("MOT DE PASSE *"),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputStyle("••••••••", Icons.lock_outline, true),
                  validator: (v) =>
                      v!.length < 6 ? "Minimum 6 caractères" : null,
                ),
                const SizedBox(height: 20),

                _buildLabel("CONFIRMER LE MOT DE PASSE *"),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: _inputStyle(
                    "••••••••",
                    Icons.lock_reset_outlined,
                    false,
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return "Les mots de passe ne correspondent pas";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _soumettreInscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF7B61FF,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Créer mon compte",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Déjà inscrit ? ",
                      style: TextStyle(color: Colors.white38),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Se connecter",
                        style: TextStyle(
                          color: Color(0xFF7B61FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType type = TextInputType.text,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: _inputStyle(hint, icon, false),
      validator: validator,
    );
  }

  InputDecoration _inputStyle(String hint, IconData icon, bool isPassword) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF7B61FF), size: 22),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white38,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      filled: true,
      fillColor: const Color(0xFF16192B),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
