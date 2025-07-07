
# 🏠 Application de Location de Maison

Cette application mobile permet aux utilisateurs de publier, consulter et réserver des biens immobiliers. Elle a été développée dans le cadre d’un **projet d’école** au sein du **Burkina Institute of Technology (BIT)** par un groupe d'étudiants en informatique.

> ⚠️ **Note** : Ce projet est encore en cours de développement et certaines fonctionnalités peuvent ne pas être complètement terminées.

---

## 🚀 Fonctionnalités principales

- ✅ Authentification des utilisateurs (locataires et bailleurs)
- 🏠 Ajout, modification et suppression de biens immobiliers
- 📷 Téléversement de plusieurs images par bien
- 📍 Visualisation des détails des biens avec galerie d’images
- 📅 Réservation d’un bien avec dates de début et de fin
- 📬 Consultation des demandes de réservation pour le bailleur
- 🔒 Accès différencié selon le rôle (locataire vs bailleur)
- 🔔 Notifications via messages ou alertes contextuelles
- 🎨 Design responsive avec animations modernes

---

## 🛠️ Technologies utilisées

- **Flutter** pour l’application mobile
- **Node.js + Express** pour le backend
- **MongoDB** comme base de données NoSQL
- **Multer** pour la gestion des fichiers images
- **SharedPreferences** pour le stockage local
- **HTTP + REST API** pour la communication client-serveur

---

## 📂 Structure du projet

- `/location_app` : App mobile Flutter
- `/backend` : API Express avec gestion des routes, contrôleurs, middleware et stockage des images
- `/uploads` : Répertoire local contenant les images des biens (accessible via API)
- `property.routes.js` : Routes REST pour les biens
- `booking.routes.js` : Routes REST pour les réservations

---

## ⚙️ Instructions pour démarrer

### ✅ Côté Backend

```bash
cd backend
npm install
npm run dev
```

Le backend est accessible à l'adresse : `http://localhost:3000`

### ✅ Côté Flutter

```bash
cd location_app
flutter pub get
flutter run
```

Pour tester sur un appareil physique : pense à remplacer `10.0.2.2` par ton IP locale dans `api_service.dart`.

---

## 👨‍🎓 Projet académique

Ce projet a été réalisé dans le cadre du cours de **Développement Mobile et Services Web (BIT/CS26)** au **Burkina Institute of Technology**.

Équipe composée de 3 étudiants.

> 💡 Ce projet vise à illustrer la mise en œuvre d’un système complet (mobile + API + base de données) dans un contexte pratique.

---

## 📸 Capture d'écran

![Aperçu](assets/images/dashboard_example.png) *(À remplacer par tes propres captures)*

---

## 🤝 Contributions

Les contributions sont les bienvenues. Il est prévu d’ajouter :
- Le paiement mobile
- La messagerie entre utilisateurs
- Un espace administrateur
- La gestion des états des réservations

---

## ✍️ Auteur·rice·s

- **Aziz THIOMBIANO**
- **Aslane OUEDRAOGO**
- **Sandrine OUEDRAOGO**

---

## 📜 Licence

© 2025 Aziz THIOMBIANO, Aslane OUEDRAOGO, Sandrine OUEDRAOGO.  
Tous droits réservés.  
Ce projet est protégé par les lois sur la propriété intellectuelle.  
Aucune partie ne peut être copiée, distribuée ou modifiée sans autorisation écrite explicite des auteur·rice·s.
