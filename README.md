<div align="center">

# 📝 Bloc-Notes App — Stockage Local & Communication API

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

Ce dépôt contient l'application complète pour le **TP Bloc-Notes** (Module Développement Mobile). L'application intègre le stockage local et la communication avec une API REST pour fonctionner de manière fluide, avec ou sans connexion Internet.

---
</div>

## 👨‍🎓 Informations de l'étudiant
- **Nom:** Mohamed salem chavii
- **Matricule:** 23067
- **Année:** L2
- **Spécialité:** DWM

---

## 🎯 Objectifs atteints (Exigences du TP)
L'application répond à 100% aux exigences définies dans l'énoncé du TP :

1. **Partie 1 - SharedPreferences (Stockage Local) :** 
   Les notes survivent à la fermeture de l'application. Elles sont enregistrées et chargées localement.
2. **Partie 2 - API REST (Communication distante) :**
   L'application est connectée à une API REST (JSONPlaceholder) permettant de récupérer (`GET`), créer (`POST`) et supprimer (`DELETE`) des notes avec la gestion des erreurs (`try/catch`).
3. **Partie 3 - Synchronisation Local + Distant :**
   L'application détecte automatiquement l'état de la connexion Internet. Elle adapte l'interface utilisateur (icône de statut) et permet l'accès aux fonctionnalités de l'API uniquement si l'appareil est connecté.

---

## ✨ Fonctionnalités
L'application propose les fonctionnalités clés suivantes :
- **Que fait l'application exactement ?** : C'est un gestionnaire de notes intelligent qui combine un stockage local pour le mode hors ligne, et une communication avec une API pour récupérer ou enregistrer des données sur un serveur distant.
- **Comment ajouter une note ?** : Cliquez sur le bouton flottant `+` en bas de l'écran, entrez un titre et un contenu, puis validez en cliquant sur "Enregistrer".
- **Comment sont-elles sauvegardées ?** : Toute note ajoutée ou modifiée est instantanément convertie en format JSON et sauvegardée dans la mémoire persistante de l'appareil via `SharedPreferences`.
- **Comment sont-elles supprimées ?** : Un simple glissement (Swipe) vers la gauche sur une note permet de la supprimer de la liste et du stockage local (ou du serveur distant).
- **Que se passe-t-il sans Internet ?** : L'application détecte automatiquement la perte de connexion. L'icône de réseau devient rouge, et l'accès au serveur API est masqué pour éviter les erreurs. Vous pouvez continuer à utiliser, ajouter, et modifier vos notes locales en toute sécurité.

---

## 🔄 Mécanisme de fonctionnement
Le flux d'exécution de l'application suit un processus logique et optimisé :
1. **Démarrage de l'application :** Flutter initialise les liaisons de base et lance la fonction asynchrone `main()`.
2. **Chargement des données locales :** Le service `NoteService` lit instantanément les notes enregistrées dans `SharedPreferences` et les charge en mémoire avant même l'affichage de l'interface.
3. **Vérification de la connexion :** Le package `connectivity_plus` vérifie l'état du réseau (via `_checkConnectivity`) et écoute les changements en temps réel.
4. **Interaction avec l'interface :** L'utilisateur visualise ses notes locales sur la `HomePage`. Si l'appareil est en ligne, le bouton de synchronisation (API) apparaît dans la barre supérieure.
5. **Accès et opérations API :** En allant sur `ApiNotesPage`, une requête HTTP `GET` est envoyée au serveur distant. L'utilisateur peut interagir avec ces données externes en créant (`POST`) ou en supprimant (`DELETE`) des notes.
6. **Sauvegarde instantanée :** À chaque modification sur les notes locales (ajout, modification, suppression), la méthode `_saveNotes()` est déclenchée en arrière-plan, réécrivant la liste entière dans le stockage du téléphone.

---

## 🛠️ Packages utilisés
- `shared_preferences: ^2.5.5` - Pour le stockage local persistant (clé-valeur).
- `http: ^1.6.0` - Pour effectuer les requêtes HTTP vers l'API REST.
- `connectivity_plus: ^7.1.1` - Pour vérifier l'état de la connexion réseau (En ligne / Hors ligne).

---

## 📁 Structure du projet
Le projet a été organisé proprement pour séparer l'interface utilisateur de la logique métier :

```text
my_app_flutter/
├── lib/
│   ├── main.dart               # Point d'entrée de l'application, initialise SharedPreferences
│   ├── models/
│   │   └── note.dart           # Modèle de données Note avec les méthodes de sérialisation toJson/fromJson
│   ├── services/
│   │   ├── note_service.dart   # Gère les opérations locales (ajout, modification, suppression)
│   │   └── api_service.dart    # Gère les requêtes vers l'API REST
│   └── pages/
│       ├── home_page.dart      # Page d'accueil affichant les notes locales et l'état de la connexion
│       └── api_notes_page.dart # Page dédiée à l'interaction avec le serveur distant
```

---

## ⚙️ Explication des fonctions principales
- `_loadNotes()` & `_saveNotes()` : Présentes dans `NoteService`, elles permettent de lire et d'enregistrer automatiquement la liste des notes en mémoire locale.
- `toJson()` & `fromJson()` : Présentes dans le modèle `Note`, elles transforment les objets en format JSON pour faciliter leur stockage ou leur envoi sur le réseau, tout en gérant correctement le type `DateTime`.
- `getAllNotes()`, `createNote()`, `deleteNote()` : Fonctions de `ApiService` effectuant les requêtes HTTP et décodant la réponse du serveur.
- `_checkConnectivity()` : Listener utilisé dans `HomePage` pour mettre à jour instantanément l'interface lorsque l'appareil gagne ou perd sa connexion Internet.

---

## 🚀 Comment exécuter le projet ?
1. Assurez-vous que l'environnement **Flutter** est correctement installé sur votre machine.
2. Clonez le dépôt :
   ```bash
   git clone https://github.com/23067-cpu/TP_flutter.git
   ```
3. Naviguez vers le répertoire du projet et installez les dépendances :
   ```bash
   cd TP_flutter/my_app_flutter
   flutter pub get
   ```
4. Lancez l'application. Pour observer le fonctionnement optimal du stockage local pendant vos tests (surtout après une fermeture), privilégiez l'exécution en tant qu'application Windows ou sur un appareil Android :
   ```bash
   flutter run -d windows
   ```

*(Note : L'exécution sur Chrome en mode Debug crée une session temporaire ; par conséquent, les données locales seront réinitialisées à la fermeture du navigateur.)*
