const fs = require('fs');
const path = require('path');
const Property = require('../models/Property');

exports.updateProperty = async (req, res) => {
  try {
    const property = await Property.findById(req.params.id);
    if (!property) return res.status(404).json({ message: "Bien non trouvé" });

    // Vérifie que l'utilisateur est le propriétaire du bien
    if (property.ownerId.toString() !== req.user.userId) {
      return res.status(403).json({ message: "Action non autorisée" });
    }

    // ✅ Mise à jour des champs standards s'ils sont fournis
    if (req.body.title) property.title = req.body.title;
    if (req.body.city) property.city = req.body.city;
    if (req.body.description) property.description = req.body.description;
    if (req.body.price) property.price = req.body.price;

    // ✅ Mise à jour des features si fournies en JSON string
    if (req.body.features) {
      try {
        property.features = JSON.parse(req.body.features);
      } catch {
        property.features = [];
      }
    }

    // ✅ Gestion des nouvelles images (remplacement complet)
    if (req.files && req.files.length > 0) {
      // Optionnel : suppression des anciennes images du disque
      // property.images.forEach(img => {
      //   const imgPath = path.join(__dirname, '..', img);
      //   if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
      // });

      // Remplacement des anciennes par les nouvelles
      property.images = req.files.map(file => `/uploads/${file.filename}`);
    }

    const updated = await property.save();
    res.status(200).json(updated);

  } catch (error) {
    console.error("Erreur de mise à jour :", error);
    res.status(500).json({ message: error.message });
  }
};
