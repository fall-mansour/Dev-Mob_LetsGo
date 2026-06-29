const db = require("../db");

// 1. RÉCUPÉRER LES INFOS DU PROFIL
exports.obtenirProfil = (req, res) => {
  const userId = req.params.id;

  const query =
    "SELECT id, nom, prenom, telephone, email, adresse FROM utilisateurs WHERE id = ?";

  db.query(query, [userId], (err, result) => {
    if (err) {
      console.error("Erreur lors de la récupération du profil :", err);
      return res
        .status(500)
        .json({ error: true, message: "Erreur interne du serveur." });
    }

    if (result.length === 0) {
      return res
        .status(404)
        .json({ error: true, message: "Utilisateur non trouvé." });
    }

    // Renvoie les données du profil de l'utilisateur
    res.status(200).json({
      error: false,
      profil: result[0],
    });
  });
};

// 2. METTRE À JOUR LES INFOS DU PROFIL (Optionnel mais très pro pour le jury)
exports.mettreAJourProfil = (req, res) => {
  const userId = req.params.id;
  const { nom, prenom, email, adresse } = req.body;

  const query =
    "UPDATE utilisateurs SET nom = ?, prenom = ?, email = ?, adresse = ? WHERE id = ?";

  db.query(query, [nom, prenom, email, adresse, userId], (err, result) => {
    if (err) {
      console.error("Erreur lors de la mise à jour du profil :", err);
      return res
        .status(500)
        .json({ error: true, message: "Erreur lors de la modification." });
    }

    res.status(200).json({
      error: false,
      message: "Profil mis à jour avec succès !",
    });
  });
};
