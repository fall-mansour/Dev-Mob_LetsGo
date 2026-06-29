const db = require("../db");
const bcrypt = require("bcrypt");

exports.connexionCompte = async (req, res) => {
  try {
    const { telephone, mot_de_passe } = req.body;

    if (!telephone || !mot_de_passe) {
      return res.status(400).json({
        status: "Erreur",
        message: "Le numéro de téléphone et le mot de passe sont obligatoires.",
      });
    }

    const queryCheck =
      "SELECT id, nom, prenom, telephone, email, photo_avatar, mot_de_passe FROM utilisateurs WHERE telephone = ?";
    const [utilisateurs] = await db.query(queryCheck, [telephone]);

    if (utilisateurs.length === 0) {
      return res.status(404).json({
        status: "Erreur",
        message: "Aucun compte LetsGo n'est associé à ce numéro de téléphone.",
      });
    }

    const utilisateur = utilisateurs[0];
    const motDePasseCorrect = await bcrypt.compare(
      mot_de_passe,
      utilisateur.mot_de_passe,
    );

    if (!motDePasseCorrect) {
      return res.status(401).json({
        status: "Erreur",
        message: "Mot de passe incorrect. Veuillez réessayer.",
      });
    }

    return res.status(200).json({
      status: "Succès",
      message: "Connexion réussie !",
      donnees: {
        id_utilisateur: utilisateur.id,
        prenom: utilisateur.prenom,
        nom: utilisateur.nom,
        telephone: utilisateur.telephone,
        email: utilisateur.email,
        photo_avatar: utilisateur.photo_avatar,
      },
    });
  } catch (erreur) {
    console.error("❌ Erreur connexion :", erreur);
    return res
      .status(500)
      .json({ status: "Erreur", message: "Erreur interne serveur." });
  }
};
