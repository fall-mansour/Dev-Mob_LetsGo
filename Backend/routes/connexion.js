const express = require("express");
const router = express.Router();
const connexionController = require("../controllers/connexion.controller.js");

// Route de connexion
router.post("/login", connexionController.connexionCompte);

module.exports = router;
