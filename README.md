#  Notely

Une application Flutter de prise de notes personnelles, connectée à un backend réel (Supabase), avec authentification, cache local et mode hors-ligne.

> Projet réalisé dans le cadre du cours *Développement Mobile* — Institut Polytechnique DEFITECH.

---

##  Table des matières

- [Aperçu](#-aperçu)
- [Fonctionnalités](#-fonctionnalités)
- [Stack technique](#-stack-technique)
- [Architecture](#-architecture)
- [Structure du projet](#-structure-du-projet)
- [Installation](#-installation)
- [Configuration Supabase](#-configuration-supabase)
- [Lancer l'application](#-lancer-lapplication)
- [Tests](#-tests)
- [Choix techniques](#-choix-techniques)
- [Limites connues](#-limites-connues)

---

##  Aperçu

Notely permet à un utilisateur de créer un compte, se connecter, puis gérer ses notes personnelles (créer, consulter, modifier, supprimer) depuis n'importe quel appareil, avec un accès à ses dernières données même sans connexion internet.

**Écrans principaux :** Splash → Connexion / Inscription → Liste des notes → Créer/Modifier une note → Profil.

---

##  Fonctionnalités

- **Authentification complète** : inscription, connexion, déconnexion via Supabase Auth (JWT)
-  **CRUD de notes** : créer, lire, modifier, supprimer ses notes personnelles
-  **Sécurité des données** : Row Level Security (RLS) — chaque utilisateur n'accède qu'à ses propres notes, garanti au niveau de la base de données
-  **Mode hors-ligne** : les notes déjà chargées restent consultables sans connexion, via un cache local (Hive)
-  **Gestion d'erreurs réseau** : messages clairs et adaptés selon la situation (hors-ligne, erreur serveur), avec option de réessayer
-  **Confidentialité des mots de passe** : affichage/masquage à la saisie
-  **Profil utilisateur** : informations du compte et nombre total de notes

---

##  Stack technique

| Domaine | Technologie |
|---|---|
| Framework | Flutter |
| Backend / API REST | [Supabase](https://supabase.com) (PostgreSQL + Auth + API REST auto-générée) |
| Authentification | Supabase Auth (JWT) |
| Cache local | Hive |
| Détection réseau | connectivity_plus |
| Gestion d'état | Provider |
| Typographie | Google Fonts (Lora + Inter) |
| Tests | flutter_test + Mockito |

---

##  Architecture

Le projet suit une **Clean Architecture** stricte, organisée par fonctionnalité (*feature-first*). Chaque feature est divisée en 3 couches indépendantes :

│ PRESENTATION │ ← Widgets, Pages, Providers (état UI)
│ (dépend uniquement du domain) │
└───────────────────┬───────────────────────┘
│
┌────────────────────▼──────────────────────┐
│ DOMAIN │ ← Entités, Repository (interfaces), Usecases
│ (aucune dépendance externe) │
└────────────────────▲──────────────────────┘
│
┌────────────────────┴──────────────────────┐
│ DATA │ ← Repository (implémentation), Datasources,
│ (Supabase, Hive — dépend du domain) │ Modèles (sérialisation JSON)
└─────────────────────────────────────────────┘


**Règle de dépendance :** les flèches ne pointent que vers l'intérieur. La couche `domain` ne connaît ni Supabase ni Hive — elle définit uniquement des contrats (interfaces). C'est la couche `data` qui les implémente. Ainsi, remplacer Supabase par un autre backend ne nécessiterait de modifier que la couche `data`, jamais `domain` ni `presentation`.

**Stratégie réseau adoptée (repository `notes`) :** *network-first, cache-fallback*
- Connecté → récupère les données fraîches depuis Supabase, puis met à jour le cache Hive
- Hors-ligne → sert directement les dernières données mises en cache
- Création/modification/suppression → nécessitent une connexion active (empêche les incohérences de synchronisation)

---

##  Structure du projet

lib/
├── core/ # Code partagé, indépendant des features
│ ├── theme/ # Couleurs, styles de texte, thème Material
│ ├── network/ # Client Supabase + détection de connectivité
│ ├── errors/ # Exceptions techniques et Failures métier
│ └── cache/ # Configuration Hive
│
├── features/
│ ├── auth/
│ │ ├── data/
│ │ │ ├── datasources/ # Appels Supabase Auth
│ │ │ ├── models/ # AppUserModel
│ │ │ └── repositories/ # Implémentation AuthRepository
│ │ ├── domain/
│ │ │ ├── entities/ # AppUser
│ │ │ └── repositories/ # Interface AuthRepository
│ │ └── presentation/
│ │ ├── pages/ # Splash, Login, Register, Profile
│ │ ├── widgets/ # AuthTextField
│ │ └── providers/ # AuthProvider (état de connexion)
│ │
│ └── notes/
│ ├── data/
│ │ ├── datasources/ # Datasource distant (Supabase) + local (Hive)
│ │ ├── models/ # NoteModel
│ │ └── repositories/ # Implémentation NotesRepository
│ ├── domain/
│ │ ├── entities/ # Note
│ │ └── repositories/ # Interface NotesRepository
│ └── presentation/
│ ├── pages/ # HomePage, NotesListPage, NoteFormPage
│ ├── widgets/ # NoteCard, OfflineBanner
│ └── providers/ # NotesProvider (état de la liste)
│
└── main.dart # Point d'entrée, injection des dépendances, routes

test/
└── features/notes/data/repositories/
└── notes_repository_impl_test.dart # Tests unitaires du repository


---

##  Installation

### Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installé
- Un compte [Supabase](https://supabase.com) (gratuit)
- Git

### Cloner le projet

```bash
git clone https://github.com/BorisDANSOU/notely.git
cd notely
flutter pub get
```

---

##  Configuration Supabase

### 1. Créer un projet Supabase

Rends-toi sur [supabase.com](https://supabase.com) → **New project**, et attends la fin du provisionnement.

### 2. Créer la table `notes`

Dans **SQL Editor**, exécute le script suivant :

```sql
create table notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index notes_user_id_idx on notes(user_id);

alter table notes enable row level security;

create policy "Users can view their own notes"
  on notes for select using (auth.uid() = user_id);

create policy "Users can insert their own notes"
  on notes for insert with check (auth.uid() = user_id);

create policy "Users can update their own notes"
  on notes for update using (auth.uid() = user_id);

create policy "Users can delete their own notes"
  on notes for delete using (auth.uid() = user_id);
```

### 3. (Recommandé) Désactiver la confirmation d'email

Pour simplifier les tests : **Authentication → Providers → Email → désactiver "Confirm email"**. Sinon, l'inscription nécessite une validation par email (soumise à une limite de débit sur le plan gratuit).

### 4. Récupérer les clés API

Dans **Project Settings → API**, note :
- `Project URL`
- `anon public key`

### 5. Créer le fichier `.env`

À la racine du projet, crée un fichier `.env` (sur le modèle de `.env.example`) :

SUPABASE_URL=https://ton-projet.supabase.co
SUPABASE_ANON_KEY=ta_anon_key


Ce fichier est ignoré par Git (`.gitignore`) — il ne doit jamais être commité.

---

##  Lancer l'application

```bash
flutter run
```

---

##  Tests

Les tests unitaires couvrent la couche `repository` de la feature `notes`, en simulant (via Mockito) les datasources distant/local et l'état réseau :

```bash
flutter test
```

**Scénarios testés :**
- Récupération des notes en ligne + mise à jour du cache
- Bascule automatique vers le cache en mode hors-ligne
- Traduction des exceptions techniques en erreurs métier (`Failure`)
- Blocage de la création de note hors-ligne
- Création d'une note en ligne + mise en cache immédiate

---

##  Choix techniques

- **Provider plutôt que Riverpod/Bloc** : suffisant pour la taille du projet, tout en illustrant clairement la séparation état/UI.
- **JSON brut dans Hive plutôt que des `TypeAdapter` générés** : les modèles disposent déjà de `toJson`/`fromJson` pour Supabase — les réutiliser pour le cache évite une duplication de la logique de sérialisation.
- **Formulaire unique pour créer et modifier une note** : les deux actions partagent exactement la même structure (titre + contenu) ; un seul widget paramétré (`NoteFormPage`) réduit la duplication sans nuire à l'expérience utilisateur.
- **Écriture/modification/suppression bloquées hors-ligne** : évite les conflits de synchronisation qu'une vraie stratégie offline-first (avec file d'attente et résolution de conflits) demanderait à gérer — hors du périmètre de ce projet.

---

##  Limites connues

- Les créations/modifications/suppressions de notes nécessitent une connexion active (seule la consultation fonctionne hors-ligne).
- Pas de récupération de mot de passe oublié implémentée.
- Le compte Supabase gratuit utilise le service d'email intégré, limité en débit (voir section Configuration).

---

##  Auteur

**Boris Vénunyé Dansou**
Étudiant en Génie Logiciel — Institut Polytechnique DEFITECH, Lomé, Togo