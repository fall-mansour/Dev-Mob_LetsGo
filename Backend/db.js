const mysql = require("mysql2");
require("dotenv").config(); // Charge les variables du fichier .env

// Configuration du pool avec valeurs par défaut de secours si le .env fait défaut
const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  // Si process.env.DB_PASSWORD vaut "" ou est indéfini, on passe une chaîne vide
  password:
    process.env.DB_PASSWORD === '""' || !process.env.DB_PASSWORD
      ? ""
      : process.env.DB_PASSWORD,
  database: process.env.DB_NAME || "letsgo",
  port: parseInt(process.env.DB_PORT || "3306"),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Conversion du pool pour utiliser les Promesses (async/await)
const db = pool.promise();

// VRAI TEST DE CONNEXION STRICT
pool.query("SELECT 1", (err) => {
  if (err) {
    console.error(
      "\n❌ [ERREUR CRITIQUE BASE DE DONNÉES] Connexion impossible !",
    );
    console.error(`👉 Code SQL : ${err.code}`);
    console.error(`👉 Message : ${err.message}`);
    console.error(
      `👉 Tentative sur la base : '${process.env.DB_NAME || "letsgo"}' avec l'utilisateur : '${process.env.DB_USER || "root"}'`,
    );
    console.error(
      "Vérifie que XAMPP/WAMP est allumé et que le nom de la base est exact.\n",
    );
  } else {
    console.log(
      `\n🟢 [MySQL] Connexion établie avec succès à la base '${process.env.DB_NAME || "letsgo"}' !`,
    );
  }
});

module.exports = db;
