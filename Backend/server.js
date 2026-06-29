const express = require("express");
const cors = require("cors");
require("dotenv").config(); // Charge le port et les variables du fichier .env

// Importation de la connexion MySQL
const db = require("./db");

const app = express();
const PORT = process.env.PORT || 3000;

// ==========================================
//            MIDDLEWARES GLOBAUX
// ==========================================

// 1. Autoriser le partage de ressources avec Flutter (CORS)
// Configuration optimale pour accepter les requêtes mobiles et locales
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
  }),
);

// 2. Permettre à Express de lire et comprendre les données au format JSON
app.use(express.json());

// 3. Permettre de lire les données de formulaires classiques
app.use(express.urlencoded({ extended: true }));

// ==========================================
//               ROUTES TESTS
// ==========================================

// Route de base pour vérifier si le serveur tourne bien dans ton navigateur
app.get("/", (req, res) => {
  res.json({
    status: "Succès",
    message:
      "Bienvenue sur l'API LetsGo ! Le serveur fonctionne parfaitement. 🚀",
    timestamp: new Date(),
  });
});

// ==========================================
//         IMPORTATION DES ROUTES ACTIVES
// ==========================================

// Branchement officiel de ta route compte.js (Inscription)
app.use("/api/compte", require("./routes/compte.js"));

// Branchement officiel de ta route connexion.js (Connexion)
app.use("/api/connexion", require("./routes/connexion.js"));

// AJOUT DE LA ROUTE PROFIL
app.use("/api/profil", require("./routes/profil.js"));

// ==========================================
//      GESTION DES ERREURS (SÉCURITÉ)
// ==========================================

// Middleware pour intercepter les routes inexistantes (Erreur 404)
app.use((req, res, next) => {
  res.status(404).json({
    error: true,
    message: `La route demandée [${req.method}] ${req.url} n'existe pas.`,
  });
});

// Middleware de gestion globale des erreurs serveur (Evite le crash de Node.js)
app.use((err, req, res, next) => {
  console.error("❌ [Erreur Serveur] :", err.stack);
  res.status(500).json({
    error: true,
    message: "Une erreur interne est survenue sur le serveur LetsGo.",
  });
});

// ==========================================
//          LANCEMENT DU SERVEUR
// ==========================================
// L'écoute sur '0.0.0.0' est INDISPENSABLE pour que l'émulateur Android (10.0.2.2)
// et les téléphones physiques connectés en Wi-Fi puissent joindre l'API.
app.listen(PORT, "0.0.0.0", () => {
  console.log(`\n==============================================`);
  console.log(`🚀 [Serveur] LetsGo démarré avec succès !`);
  console.log(`📡 Écoute locale : http://localhost:${PORT}`);
  console.log(
    `📱 Pour l'émulateur Android, utilise l'adresse : http://10.0.2.2:${PORT}`,
  );
  console.log(`==============================================\n`);
});
