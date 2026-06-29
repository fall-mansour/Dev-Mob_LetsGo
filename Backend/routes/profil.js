const express = require("express");
const router = express.Router();
const profilController = require("../controllers/profil.controller");

// Route pour récupérer le profil : GET /api/profil/:id
router.get("/:id", profilController.obtenirProfil);

// Route pour modifier le profil : PUT /api/profil/:id
router.put("/:id", profilController.mettreAJourProfil);

module.exports = router;
