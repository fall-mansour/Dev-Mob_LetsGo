const express = require("express");
const router = express.Router();
const compteController = require("../controllers/compte.controller.js");

// Route d'inscription
router.post("/register", compteController.creerCompte);

module.exports = router;
