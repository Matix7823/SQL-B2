-- ============================================================
-- DONNÉES DE RÉFÉRENCE
-- ============================================================

-- 1. Stations
INSERT INTO stations (station_id, nom, adresse, ville, capacite_bornes) VALUES 
(1, 'Station Bordeaux', 'Centre ville', 'Bordeaux', 50),
(2, 'Station Lille', 'Gare Flandres', 'Lille', 50),
(3, 'Station Lyon', 'Part-Dieu', 'Lyon', 60),
(4, 'Station Marseille', 'Vieux Port', 'Marseille', 55),
(5, 'Station Montpellier', 'Comédie', 'Montpellier', 40),
(6, 'Station Nantes', 'Machines de l''île', 'Nantes', 45),
(7, 'Station Nice', 'Promenade', 'Nice', 50),
(8, 'Station Paris', 'Tour Eiffel', 'Paris', 80),
(9, 'Station Strasbourg', 'Cathédrale', 'Strasbourg', 40),
(10, 'Station Toulouse', 'Capitole', 'Toulouse', 50);

-- 2. Types Véhicules
INSERT INTO types_vehicule (type_id, libelle, prix_deblocage, prix_minute) VALUES 
(1, 'Trottinette', 1.00, 0.15),
(2, 'Vélo Electrique', 1.50, 0.25),
(3, 'Scooter', 2.00, 0.35),
(4, 'Voiture Electrique', 3.00, 0.50);

-- 3. Utilisateurs
INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role) VALUES 
('Dupont', 'Alice', 'alice@gmail.com', 'pass123', 'client'),
('Martin', 'Lucas', 'lucas@yahoo.com', 'pass456', 'client'),
('Durand', 'Paul', 'paul.tech@clara.com', 'admin', 'technicien'),
('Admin', 'System', 'admin@clara.com', 'root', 'admin');

-- ============================================================
-- IMPORTATION VÉHICULES
-- ============================================================

INSERT INTO vehicules (type_id, modele, immatriculation, niveau_batterie, statut, station_actuelle_id, qr_code, annee, autonomie) VALUES 
(4, 'Kia EV6', 'XR-964-LJ', 100, 'maintenance', 9, 'QR-1-XR', 2022, 320),
(4, 'Kia EV6', 'OY-932-RY', 100, 'maintenance', 6, 'QR-2-OY', 2024, 270),
(4, 'Hyundai Ioniq 5', 'BJ-663-FL', 100, 'hors_service', 4, 'QR-3-BJ', 2022, 380),
(4, 'Kia EV6', 'MW-909-XP', 100, 'hors_service', 5, 'QR-4-MW', 2024, 480),
(4, 'Mercedes EQA', 'UN-317-LM', 100, 'maintenance', 3, 'QR-5-UN', 2021, 390),
(4, 'BMW iX1', 'FY-521-AB', 100, 'disponible', 10, 'QR-6-FY', 2023, 440),
(4, 'Nissan Ariya', 'DL-293-CK', 100, 'disponible', 7, 'QR-7-DL', 2023, 400),
(4, 'Toyota bZ4X', 'PR-881-MS', 100, 'disponible', 2, 'QR-8-PR', 2023, 450),
(4, 'Renault Megane E-Tech', 'GT-104-LZ', 100, 'disponible', 3, 'QR-9-GT', 2022, 300),
(4, 'Citroen e-C4', 'HW-775-NQ', 100, 'disponible', 8, 'QR-10-HW', 2022, 350),
(4, 'Volkswagen ID.4', 'KV-332-OP', 100, 'disponible', 5, 'QR-11-KV', 2023, 400),
(4, 'Tesla Model Y', 'ZA-659-RT', 100, 'en_location', NULL, 'QR-12-ZA', 2023, 450),
(4, 'Peugeot e-2008', 'BX-418-YU', 100, 'disponible', 9, 'QR-13-BX', 2021, 320),
(4, 'Fiat 500e', 'CN-902-WI', 100, 'maintenance', 1, 'QR-14-CN', 2020, 320),
(4, 'Kia Niro EV', 'DM-156-QA', 100, 'disponible', 4, 'QR-15-DM', 2023, 460),
(4, 'Hyundai Kona Electric', 'EP-743-SD', 100, 'disponible', 8, 'QR-16-EP', 2022, 300),
(4, 'Mercedes EQB', 'FG-284-FJ', 100, 'disponible', 7, 'QR-17-FG', 2023, 420),
(4, 'BMW i4', 'GH-639-GK', 100, 'en_location', NULL, 'QR-18-GH', 2024, 590),
(4, 'Nissan Leaf', 'HJ-891-HL', 100, 'disponible', 6, 'QR-19-HJ', 2021, 270),
(4, 'Toyota bZ4X', 'JK-562-ZM', 100, 'disponible', 10, 'QR-20-JK', 2023, 450);

-- Ajustement séquence ID
PERFORM setval('vehicules_vehicule_id_seq', (SELECT MAX(vehicule_id) FROM vehicules));

-- 1. Location terminée (avec paiement)
INSERT INTO locations (user_id, vehicule_id, station_depart_id, station_arrivee_id, date_debut, date_fin, duree_minutes, cout_total) VALUES 
(1, 9, 3, 3, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '45 minutes', 45, estimer_cout_trajet(4, 45));

INSERT INTO paiements (location_id, montant, statut) VALUES 
(1, estimer_cout_trajet(4, 45), 'paye');

-- 2. Location en cours 
-- Trigger mettra à jour le statut
INSERT INTO locations (user_id, vehicule_id, station_depart_id, date_debut) VALUES 
(2, 12, 8, NOW() - INTERVAL '30 minutes');

-- 3. Maintenance
INSERT INTO maintenances (vehicule_id, technicien_id, type_intervention, commentaires) VALUES 
(1, 3, 'Révision Batterie', 'Erreur charge critique');