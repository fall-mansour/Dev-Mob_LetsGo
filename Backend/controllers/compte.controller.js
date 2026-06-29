const db = require("../db"); // Import de ton pool de connexion MySQL
const bcrypt = require("bcrypt"); // Nécessaire pour hacher le mot de passe

exports.creerCompte = async (req, res) => {
  try {
    // 1. Extraction de toutes les variables envoyées par l'application Flutter
    const { nom, prenom, telephone, email, mot_de_passe, adresse } = req.body;

    // Message de débogage dans ton terminal pour confirmer la réception de la requête
    console.log(
      `\n📨 [API Inscription] Requête reçue pour : ${prenom} ${nom} (${telephone})`,
    );

    // 2. Validation stricte des champs obligatoires
    if (!nom || !prenom || !telephone || !mot_de_passe) {
      console.log(
        "⚠️ Échec de validation : Certains champs obligatoires sont manquants.",
      );
      return res.status(400).json({
        status: "Erreur",
        message:
          "Les champs Nom, Prénom, Téléphone et Mot de passe sont obligatoires.",
      });
    }

    // 3. Vérification de l'existence du numéro de téléphone dans MySQL (contrainte UNIQUE)
    const [utilisateurExistant] = await db.query(
      "SELECT id FROM utilisateurs WHERE telephone = ?",
      [telephone],
    );

    if (utilisateurExistant.length > 0) {
      console.log(
        `🚫 Inscription refusée : Le numéro ${telephone} possède déjà un compte.`,
      );
      return res.status(400).json({
        status: "Erreur",
        message: "Ce numéro de téléphone est déjà associé à un compte LetsGo.",
      });
    }

    // 4. Sécurisation : Hachage du mot de passe avec Bcrypt
    console.log("🔑 Hachage du mot de passe en cours...");
    const saltRounds = 10;
    const motDePasseHache = await bcrypt.hash(mot_de_passe, saltRounds);

    // 5. Exécution de la requête d'insertion SQL
    const queryInsertion = `
            INSERT INTO utilisateurs (nom, prenom, telephone, email, mot_de_passe, adresse) 
            VALUES (?, ?, ?, ?, ?, ?)
        `;

    console.log("💾 Écriture dans la base de données MySQL...");
    const [resultat] = await db.query(queryInsertion, [
      nom.trim(),
      prenom.trim(),
      telephone.trim(),
      email ? email.trim() : null,
      motDePasseHache,
      adresse ? adresse.trim() : null,
    ]);

    // 6. Analyse du résultat retourné par MySQL dans la console
    console.log("📊 [MySQL] Résultat renvoyé par la base de données :");
    console.log(
      `   - ID de l'utilisateur généré (insertId) : ${resultat.insertId}`,
    );
    console.log(
      `   - Lignes insérées (affectedRows) : ${resultat.affectedRows}`,
    );

    // Double vérification de sécurité : si affectedRows vaut 0, l'insertion a échoué
    if (resultat.affectedRows === 0) {
      throw new Error(
        "MySQL a accepté la requête mais aucune ligne n'a été ajoutée.",
      );
    }

    // 7. Envoi de la réponse HTTP de succès à Flutter (Statut 201 Created)
    console.log("✅ Compte créé avec succès ! Réponse envoyée au client.");
    return res.status(201).json({
      status: "Succès",
      message: "Compte créé avec succès !",
      donnees: {
        id_utilisateur: resultat.insertId,
        prenom: prenom,
        nom: nom,
        telephone: telephone,
        email: email || null,
        adresse: adresse || null,
      },
    });
  } catch (erreur) {
    // En cas de plantage (Erreur de syntaxe SQL, mauvaise configuration de table, etc.)
    console.error(
      "\n❌ [CRITIQUE] Erreur serveur lors de la création de compte :",
    );
    console.error(erreur.message);

    return res.status(500).json({
      status: "Erreur",
      message: "Une erreur interne est survenue sur le serveur.",
      details: erreur.message, // Utile pour débugger pendant la phase de développement
    });
  }
};
