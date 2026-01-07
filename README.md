# 🚗 clara Mobility - Projet SQL B2

## Description
Projet de gestion de base de données pour une flotte de véhicules électriques partagés.
Inclut la modélisation, la création SQL PostgreSQL et l'analyse de données (CSV 2025).

## Structure
* **Stations** : 10 villes (Bordeaux, Lille, Lyon, Paris...)
* **Véhicules** : Flotte électrique (Tesla, Kia, Renault...) avec autonomie et année.
* **Utilisateurs** : Clients, Techniciens, Admins.
* **Locations** : Historique et calcul automatique des coûts.

## Installation
1.  Créer une base de données `clara_mobility` sur PostgreSQL.
2.  Exécuter `create_tables.sql` (Structure + Triggers).
3.  Exécuter `insert_data.sql` (Données CSV + Tests).
4.  Exécuter `queries.sql` (Analyses).

## Fonctionnalités Avancées
* **Trigger** : Mise à jour automatique du statut du véhicule (Disponible <-> En location).
* **Fonction** : Calcul du prix dynamique selon le type et la durée.
* **Vue** : Dashboard administrateur (KPIs).

## Auteur
Projet SQL B2.