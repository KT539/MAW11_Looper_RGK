# MAW11_Looper_RGK

## Prérequis

- Ruby 3.3 ou plus récent, avec Bundler ;
- un serveur MySQL accessible localement ;
- une base de données initialisée avec le schéma de [`db/db_create.sql`](db/db_create.sql).

## Configuration

Crée un fichier `.env` à la racine du projet avec les informations de connexion MySQL :

```env
DB_HOST=127.0.0.1
DB_USERNAME=ton_utilisateur_mysql
DB_PASSWORD=ton_mot_de_passe_mysql
DB_DATABASE=MAW11_Looper_RGK
```

Pour créer la base et les tables `forms` et `labels`, exécute le script SQL :

> Attention : ce script supprime puis recrée la base `MAW11_Looper_RGK`.

```bash
mysql -u ton_utilisateur_mysql -p < db/db_create.sql
```

Installe ensuite les dépendances Ruby :

```bash
bundle install
```

## Lancer le projet

```bash
bundle exec ruby main.rb -p 4567
```

Ouvre ensuite [http://localhost:4567/](http://localhost:4567/).

Le formulaire crée une entrée dans `forms` avec le statut `Building`, génère une page basée sur `Site_remastered/exercises/template/fields.html`, puis redirige vers cette page.
