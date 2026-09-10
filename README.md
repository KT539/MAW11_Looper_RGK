# MAW11 — Looper

Application web locale de création et de réponse à des exercices. Le projet combine une interface HTML/CSS existante, une application Ruby/Sinatra et une base MySQL.

## Sommaire

- [Fonctionnement](#fonctionnement)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Lancer l’application](#lancer-lapplication)
- [Méthode de travail](#méthode-de-travail)
- [Dépannage](#dépannage)

## Fonctionnement

1. Depuis la page d’accueil, la création d’un exercice est accessible via le formulaire dédié.
2. La création d’un titre ajoute un enregistrement dans `forms` avec le statut `Building`.
3. Une page temporaire `Site_remastered/exercises/<id>/fields.html` est générée à partir du modèle `template/fields.html`.
4. Chaque « New Field » ajoute une ligne à la table `labels`, puis la page temporaire est régénérée : le champ apparaît dans le tableau de gauche.
5. Le bouton « Complete and be ready for answers » passe le formulaire à `Answering`, supprime sa page temporaire et redirige vers `exercises.html`.
6. À cette même étape, les autres dossiers numériques temporaires âgés de plus de 24 heures sont supprimés. Le dossier `template` n’est jamais concerné.

## Architecture

```text
.
├── main.rb                         # Routes Sinatra, accès MySQL et génération des pages
├── Gemfile                         # Dépendances Ruby
├── .env                            # Identifiants MySQL locaux (non versionné)
├── db/
│   ├── db_create.sql               # Création de la base et des tables
│   └── *.drawio.png                # Schémas de données
└── Site_remastered/
    ├── index.html                  # Page d’accueil
    ├── exercises.html              # Liste statique des exercices
    ├── exercises/new.html          # Formulaire de création
    ├── exercises/template/fields.html # Modèle d’une page de champs
    └── assets/                     # Feuilles de style, logo et polices
```

### Technologies

| Élément | Usage |
| --- | --- |
| Ruby 3.3+ | Langage du serveur |
| Sinatra | Routes HTTP et serveur web local |
| Puma / Rackup | Serveur HTTP utilisé par Sinatra |
| MySQL 8+ (ou compatible) | Stockage des formulaires et champs |
| `mysql2` | Connexion Ruby ↔ MySQL |
| `dotenv` | Chargement des variables depuis `.env` |

### Environnement de référence

Le projet a été vérifié avec l’environnement suivant. Les versions plus récentes compatibles devraient également fonctionner.

| Composant | Version vérifiée |
| --- | --- |
| Ruby | 3.3.8 |
| Sinatra | 4.2.1 |
| Puma | 8.0.2 |
| Rackup | 2.3.1 |
| rerun | 0.14.0 |
| mysql2 | 0.5.7 |
| dotenv | 3.2.0 |
| MariaDB client | 11.8.6 (compatible MySQL) |
| JetBrains DataGrip | 2026.2.4 |
| JetBrains RubyMine | 2026.2.1 |

## Prérequis

Il faut disposer de :

- Git ;
- Ruby **3.3 ou plus récent** avec RubyGems et Bundler ;
- MySQL Server et la commande `mysql` accessible dans le terminal ;
- un compte MySQL ayant accès à la base `MAW11_Looper_RGK`.

Les outils installés peuvent être contrôlés avec :

```bash
git --version
ruby --version
bundle --version
mysql --version
```

## Installation

### 1. Récupérer le projet

```bash
git clone <URL_DU_DEPOT>
cd MAW11_Looper_RGK
```

Si le projet est déjà présent localement, se placer simplement dans son dossier.

### 2. Installer Ruby et MySQL

#### macOS (Homebrew)

```bash
brew install ruby mysql
brew services start mysql
```

Après l’installation de Ruby, fermer puis rouvrir le terminal. Si macOS utilise encore une ancienne version de Ruby, ajouter le chemin indiqué par Homebrew à la variable `PATH`.

#### Linux (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install ruby-full ruby-dev build-essential default-libmysqlclient-dev mysql-server
sudo systemctl enable --now mysql
```

Pour Fedora, Arch ou une autre distribution, installe les équivalents de Ruby, des outils de compilation, des en-têtes MySQL/MariaDB et du serveur MySQL.

#### Windows

1. Installe [RubyInstaller avec DevKit](https://rubyinstaller.org/) (Ruby 3.3 ou plus récent) et accepte l’installation des outils MSYS2 quand elle est proposée.
2. Installe [MySQL Community Server](https://dev.mysql.com/downloads/mysql/) et conserve le mot de passe du compte administrateur créé pendant l’installation.
3. Ajoute le dossier `bin` de MySQL à la variable d’environnement `Path` si la commande `mysql` n’est pas reconnue.
4. Ouvrir un nouveau PowerShell ou Git Bash, puis contrôler `ruby --version` et `mysql --version`.

### 3. Installer les dépendances Ruby

Depuis la racine du projet :

```bash
bundle config set path vendor/bundle
bundle install
```

`vendor/bundle` est ignoré par Git : les gems restent donc locales à chaque machine.

## Configuration

### 1. Créer le fichier `.env`

Créer un fichier nommé `.env` à la racine du projet. Ne jamais le commit : il est déjà ignoré par Git.

```env
DB_HOST=127.0.0.1
DB_USERNAME=utilisateur_mysql
DB_PASSWORD=ton_mot_de_passe_mysql
DB_DATABASE=MAW11_Looper_RGK
```

Exemple : avec le compte local `root`, remplacer `utilisateur_mysql` par `root` et renseigner son mot de passe. Ce fichier ne doit jamais être publié.

### 2. Créer ou réinitialiser la base

Le script crée les tables suivantes :

| Table | Rôle |
| --- | --- |
| `forms` | Exercices : `id`, `name`, `status` |
| `labels` | Champs : `label_name`, `type`, `form_id` |

> **Attention :** `db/db_create.sql` exécute `DROP DATABASE IF EXISTS`. Il supprime donc entièrement la base `MAW11_Looper_RGK` et toutes ses données avant de la recréer.

#### macOS / Linux / Git Bash sous Windows

```bash
mysql -u root -p < db/db_create.sql
```

#### PowerShell sous Windows

```powershell
Get-Content db/db_create.sql | mysql -u root -p
```

Un autre compte peut être utilisé à la place de `root` si nécessaire. Ce compte doit avoir les droits de créer et supprimer la base. Pour l’exécution quotidienne de l’application, le compte renseigné dans `.env` doit avoir les droits sur `MAW11_Looper_RGK`.

### 3. Vérifier la base

```bash
mysql -u utilisateur_mysql -p MAW11_Looper_RGK
```

Puis, dans MySQL :

```sql
SHOW TABLES;
DESCRIBE forms;
DESCRIBE labels;
```

## Lancer l’application

À la racine du projet :

```bash
bundle exec ruby main.rb -p 4567
```

L’application est ensuite accessible sur [http://localhost:4567/](http://localhost:4567/). Cette adresse ouvre `Site_remastered/index.html`.

Pour arrêter le serveur, utiliser `Ctrl+C` dans le terminal qui l’exécute.

### Redémarrage automatique en développement

La gem `rerun` est présente dans le projet. Elle redémarre le serveur lors d’une modification de fichier Ruby :

```bash
bundle exec rerun 'ruby main.rb -p 4567'
```

Cette commande ne doit pas être utilisée en même temps qu’un autre serveur sur le port 4567.

## Méthode de travail

### Démarrage d’une session

1. Démarrer MySQL.
2. Ouvrir un terminal à la racine du projet.
3. Contrôler que `.env` contient les bonnes valeurs.
4. Lancer Sinatra avec `bundle exec ruby main.rb -p 4567`.
5. Utiliser exclusivement `http://localhost:4567/` dans le navigateur — et non l’aperçu HTML de l’IDE sur un autre port.

### Après une modification

- Modifie les routes et la logique dans `main.rb`.
- Modifie la structure de la page des champs dans `Site_remastered/exercises/template/fields.html`.
- Modifie le style dans `Site_remastered/assets/style.css`.
- Redémarrer Sinatra, ou utiliser `rerun`.
- Vérifier la syntaxe Ruby avant un test :

  ```bash
  bundle exec ruby -c main.rb
  ```

### Vérifier les données créées

```bash
mysql -u utilisateur_mysql -p MAW11_Looper_RGK -e "SELECT id, name, status FROM forms ORDER BY id DESC;"
mysql -u utilisateur_mysql -p MAW11_Looper_RGK -e "SELECT id, label_name, type, form_id FROM labels ORDER BY id DESC;"
```

### Règles importantes

- Ne jamais partager `.env`, même dans une capture d’écran ou un commit.
- N’exécuter `db/db_create.sql` qu’en acceptant la perte des données locales actuelles.
- Les dossiers `Site_remastered/exercises/<id>/` sont temporaires : ne pas les utiliser pour stocker du travail durable.
- Ne pas modifier directement une page temporaire : elle est réécrite après chaque ajout de champ.
- Utiliser systématiquement des requêtes préparées pour les futures requêtes MySQL.

## Dépannage

### `Sinatra could not start` ou gems manquantes

```bash
bundle install
```

### `Can't connect to MySQL server`

- Contrôler que MySQL est démarré.
- Contrôler `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` et `DB_DATABASE` dans `.env`.
- Contrôler la connexion avec :

  ```bash
  mysql -u utilisateur_mysql -p -h 127.0.0.1 MAW11_Looper_RGK
  ```

### Le port 4567 est déjà utilisé

Arrêter l’autre instance de Sinatra, ou démarrer celle-ci sur un autre port :

```bash
bundle exec ruby main.rb -p 4568
```

En cas de changement de port, adapter aussi les URLs `localhost:4567` générées par l’application dans `main.rb`.

### La gem `mysql2` ne s’installe pas

- Sous Linux, installe `default-libmysqlclient-dev` et `build-essential`, puis relance `bundle install`.
- Sous macOS, contrôler que MySQL est installé avec Homebrew, puis relancer `bundle install`.
- Sous Windows, confirmer l’installation de RubyInstaller **avec DevKit** et de MySQL Server ; rouvrir le terminal avant de relancer `bundle install`.

### Erreur 404 lors de l’envoi d’un formulaire

Le serveur Ruby doit être lancé et la navigation doit partir de `http://localhost:4567/`. Un aperçu HTML fourni par un IDE ne connaît pas les routes Sinatra ni la base de données.

## Commandes utiles

```bash
# Vérifier la syntaxe Ruby
bundle exec ruby -c main.rb

# Installer / mettre à jour les gems
bundle install

# Démarrer le serveur
bundle exec ruby main.rb -p 4567

# Démarrer avec redémarrage automatique
bundle exec rerun 'ruby main.rb -p 4567'
```
