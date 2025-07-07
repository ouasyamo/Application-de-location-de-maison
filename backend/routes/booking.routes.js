const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Booking = require('../models/Booking');
const verifyToken = require('../middleware/authMiddleware');
const checkRole = require('../middleware/roleMiddleware');

// ⚙️ Config multer pour upload image
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/bookings');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  },
});
const upload = multer({ storage });

/**
 * ➕ POST /bookings → créer une réservation (locataire)
 */
router.post('/', verifyToken, checkRole(['renter']), upload.array('images'), async (req, res) => {
  try {
    const {
      propertyId,
      message,
      ownerId,
      propertyTitle,
      renterName,
      startDate,
      endDate
    } = req.body;

    if (!propertyId || !ownerId || !startDate || !endDate) {
      return res.status(400).json({ message: "Champs requis manquants" });
    }

    if (new Date(startDate) >= new Date(endDate)) {
      return res.status(400).json({ message: "La date de fin doit être après la date de début." });
    }

    const imagePaths = req.files ? req.files.map(file => `/uploads/bookings/${file.filename}`) : [];

    const newBooking = new Booking({
      propertyId,
      renterId: req.user.userId,
      renterName: renterName || "Locataire",
      propertyTitle,
      ownerId,
      message,
      startDate,
      endDate,
      images: imagePaths,
      status: 'pending',
      createdAt: new Date(),
    });

    const savedBooking = await newBooking.save();
    res.status(201).json(savedBooking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

/**
 * 🔍 GET /bookings/owner/:ownerId → réservations reçues par un bailleur
 */
router.get('/owner/:ownerId', verifyToken, checkRole(['landlord']), async (req, res) => {
  try {
    if (req.params.ownerId !== req.user.userId) {
      return res.status(403).json({ message: "Accès interdit" });
    }

    // 🔥 ici on populate pour avoir les infos du bien (titre, etc.)
    const bookings = await Booking.find({ ownerId: req.user.userId })
      .populate('propertyId')
      .exec();

    res.status(200).json(bookings);
  } catch (error) {
    res.status(500).json({ message: "Erreur serveur lors de la récupération." });
  }
});

/**
 * 🔍 GET /bookings/user/:userId → voir ses propres réservations (locataire)
 */
router.get('/user/:userId', verifyToken, checkRole(['renter']), async (req, res) => {
  try {
    if (req.params.userId !== req.user.userId) {
      return res.status(403).json({ message: "Accès interdit" });
    }

    // 🔥 ici aussi on populate le bien pour affichage côté locataire
    const bookings = await Booking.find({ renterId: req.user.userId })
      .populate('propertyId')
      .exec();

    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

/**
 * ✏️ PUT /bookings/:id/status → modifier statut (accept/reject)
 */
router.put('/:id/status', verifyToken, checkRole(['landlord']), async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id).populate('propertyId');

    if (!booking) {
      return res.status(404).json({ message: "Demande non trouvée" });
    }

    if (booking.propertyId.ownerId.toString() !== req.user.userId) {
      return res.status(403).json({ message: "Action non autorisée" });
    }

    const { status } = req.body;
    if (!['pending', 'accepted', 'rejected'].includes(status)) {
      return res.status(400).json({ message: "Statut invalide" });
    }

    booking.status = status;
    await booking.save();

    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
