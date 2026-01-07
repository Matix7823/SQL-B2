[cite_start]-- 1. VUE DASHBOARD (Tableau de bord Admin)
CREATE OR REPLACE VIEW vue_dashboard_admin AS
SELECT 
    (SELECT COUNT(*) FROM utilisateurs WHERE role='client') AS total_clients,
    (SELECT COUNT(*) FROM vehicules WHERE statut='disponible') AS vehicules_dispos,
    (SELECT COUNT(*) FROM vehicules WHERE statut='maintenance') AS en_maintenance,
    (SELECT COALESCE(SUM(montant),0) FROM paiements WHERE statut='paye') AS chiffre_affaires;

SELECT * FROM vue_dashboard_admin;

[cite_start]-- 2. LISTE DES VÉHICULES DISPONIBLES PAR VILLE
SELECT s.ville, v.modele, v.autonomie 
FROM vehicules v
JOIN stations s ON v.station_actuelle_id = s.station_id
WHERE v.statut = 'disponible'
ORDER BY s.ville;

[cite_start]-- 3. CHIFFRE D'AFFAIRES PAR TYPE DE VÉHICULE
SELECT t.libelle, SUM(l.cout_total) as ca_total
FROM locations l
JOIN vehicules v ON l.vehicule_id = v.vehicule_id
JOIN types_vehicule t ON v.type_id = t.type_id
WHERE l.cout_total IS NOT NULL
GROUP BY t.libelle;

[cite_start]-- 4. CLIENTS SANS LOCATION (Sous-requête)
SELECT nom, prenom, email 
FROM utilisateurs 
WHERE role = 'client' 
AND user_id NOT IN (SELECT DISTINCT user_id FROM locations);

-- 5. VÉHICULES AVEC GROSSE AUTONOMIE (> 400km)
SELECT modele, autonomie, statut FROM vehicules WHERE autonomie > 400;

[cite_start]-- 6. TOP STATION (Celle qui a le plus de véhicules actuellement)
SELECT s.nom, COUNT(v.vehicule_id) as nb_vehicules
FROM stations s
JOIN vehicules v ON s.station_id = v.station_actuelle_id
GROUP BY s.nom
ORDER BY nb_vehicules DESC
LIMIT 1;

-- 7. MOYENNE D'ÂGE DES VÉHICULES
SELECT AVG(2025 - annee) as age_moyen_flotte FROM vehicules;

-- 8. FORMATAGE NOM CLIENT (Fonction String)
SELECT CONCAT(UPPER(nom), ' ', prenom) as identite FROM utilisateurs;

-- 9. LISTE DES MAINTENANCES EN COURS
SELECT v.modele, m.type_intervention, u.nom as technicien
FROM maintenances m
JOIN vehicules v ON m.vehicule_id = v.vehicule_id
JOIN utilisateurs u ON m.technicien_id = u.user_id;

[cite_start]-- 10. ESTIMATION PRIX (Test fonction)
SELECT estimer_cout_trajet(4, 60) as prix_1h_voiture;