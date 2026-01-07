-- ============================================================
-- 1. NETTOYAGE
-- ============================================================
DROP TRIGGER IF EXISTS trg_debut_loc ON locations;
DROP TRIGGER IF EXISTS trg_fin_loc ON locations;
DROP FUNCTION IF EXISTS action_debut_location();
DROP FUNCTION IF EXISTS action_fin_location();
DROP FUNCTION IF EXISTS estimer_cout_trajet(INT, INT);
DROP VIEW IF EXISTS vue_dashboard_admin;
DROP TABLE IF EXISTS paiements CASCADE;
DROP TABLE IF EXISTS maintenances CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS vehicules CASCADE;
DROP TABLE IF EXISTS types_vehicule CASCADE;
DROP TABLE IF EXISTS utilisateurs CASCADE;
DROP TABLE IF EXISTS stations CASCADE;

-- ============================================================
-- 2. TABLES
-- ============================================================

CREATE TABLE stations (
    station_id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    adresse TEXT NOT NULL,
    ville VARCHAR(50) NOT NULL,
    capacite_bornes INT DEFAULT 50 CHECK (capacite_bornes > 0)
);

CREATE TABLE types_vehicule (
    type_id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    prix_deblocage DECIMAL(4, 2) DEFAULT 1.00,
    prix_minute DECIMAL(4, 2) NOT NULL
);

CREATE TABLE utilisateurs (
    user_id SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(100) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('client', 'technicien', 'admin')) DEFAULT 'client',
    date_inscription DATE DEFAULT CURRENT_DATE
);

CREATE TABLE vehicules (
    vehicule_id SERIAL PRIMARY KEY,
    type_id INT REFERENCES types_vehicule(type_id),
    modele VARCHAR(100) NOT NULL,
    immatriculation VARCHAR(20) UNIQUE,
    niveau_batterie INT CHECK (niveau_batterie BETWEEN 0 AND 100) DEFAULT 100,
    statut VARCHAR(20) CHECK (statut IN ('disponible', 'en_location', 'maintenance', 'hors_service')) DEFAULT 'disponible',
    station_actuelle_id INT REFERENCES stations(station_id),
    qr_code VARCHAR(50) UNIQUE NOT NULL,
    annee INT,
    autonomie INT
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES utilisateurs(user_id) ON DELETE CASCADE,
    vehicule_id INT REFERENCES vehicules(vehicule_id) ON DELETE CASCADE,
    station_depart_id INT REFERENCES stations(station_id),
    station_arrivee_id INT REFERENCES stations(station_id),
    date_debut TIMESTAMP DEFAULT NOW(),
    date_fin TIMESTAMP,
    duree_minutes INT,
    cout_total DECIMAL(10, 2)
);

CREATE TABLE maintenances (
    maintenance_id SERIAL PRIMARY KEY,
    vehicule_id INT REFERENCES vehicules(vehicule_id) ON DELETE CASCADE,
    technicien_id INT REFERENCES utilisateurs(user_id),
    date_intervention DATE DEFAULT CURRENT_DATE,
    type_intervention VARCHAR(100),
    cout_intervention DECIMAL(10, 2),
    commentaires TEXT
);

CREATE TABLE paiements (
    paiement_id SERIAL PRIMARY KEY,
    location_id INT REFERENCES locations(location_id) ON DELETE CASCADE,
    montant DECIMAL(10, 2) NOT NULL,
    date_paiement TIMESTAMP DEFAULT NOW(),
    statut VARCHAR(20) CHECK (statut IN ('paye', 'en_attente', 'echoue')) DEFAULT 'paye'
);

-- ============================================================
-- 3. LOGIQUE (FONCTIONS & TRIGGERS)
-- ============================================================

-- Fonction calcul coût
CREATE OR REPLACE FUNCTION estimer_cout_trajet(p_type_id INT, p_duree INT) 
RETURNS DECIMAL AS $$
DECLARE
    v_deblocage DECIMAL;
    v_minute DECIMAL;
BEGIN
    SELECT prix_deblocage, prix_minute INTO v_deblocage, v_minute 
    FROM types_vehicule WHERE type_id = p_type_id;
    RETURN COALESCE(v_deblocage + (v_minute * p_duree), 0);
END;
$$ LANGUAGE plpgsql;

-- Trigger Début Location
CREATE OR REPLACE FUNCTION action_debut_location() RETURNS TRIGGER AS $$
BEGIN
    UPDATE vehicules 
    SET statut = 'en_location', station_actuelle_id = NULL
    WHERE vehicule_id = NEW.vehicule_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_debut_loc
AFTER INSERT ON locations
FOR EACH ROW
EXECUTE FUNCTION action_debut_location();

-- Trigger Fin Location
CREATE OR REPLACE FUNCTION action_fin_location() RETURNS TRIGGER AS $$
BEGIN
    IF OLD.date_fin IS NULL AND NEW.date_fin IS NOT NULL THEN
        UPDATE vehicules 
        SET statut = 'disponible', station_actuelle_id = NEW.station_arrivee_id
        WHERE vehicule_id = NEW.vehicule_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_fin_loc
AFTER UPDATE ON locations
FOR EACH ROW
EXECUTE FUNCTION action_fin_location();