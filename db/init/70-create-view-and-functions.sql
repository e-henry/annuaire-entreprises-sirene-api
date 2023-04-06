
DROP VIEW IF EXISTS etablissements_view;

CREATE VIEW etablissements_view AS 
    SELECT 
        T.activiteprincipaleetablissement as activite_principale, 
        T.nomenclatureactiviteprincipaleetablissement as nomenclature_activite_principale_etablissement,
        N.activite_principale_entreprise, 
        T.activiteprincipaleregistremetiersetablissement as activite_principale_registre_metier, 
        N.categorie_entreprise, 
        T.codecedexetablissement as cedex, 
        T.codepostaletablissement as code_postal, 
        T.datecreationetablissement as date_creation, 
        N.date_creation_entreprise, 
        T.datedebut as date_debut_activite, 
        N.date_mise_a_jour, 
        T.enseigne1etablissement as enseigne, 
        T.geo_adresse, 
        T.geo_id, 
        T.geo_l4, 
        T.geo_l5, 
        T.geo_ligne, 
        T.geo_score, 
        T.geo_type, 
        T.etablissementsiege as is_siege, 
        T.latitude, 
        T.libellecommuneetablissement as libelle_commune, 
        T.libellevoieetablissement as libelle_voie, 
        T.indicerepetitionetablissement as indice_repetition,
        T.longitude, 
        N.nature_juridique_entreprise, 
        T.nic, 
        N.nic_siege, 
        N.nom, 
        N.nom_raison_sociale, 
        T.numerovoieetablissement as numero_voie, 
        N.prenom, 
        N.sexe, 
        N.sigle, 
        N.siren, 
        N.geo_adresse as siege_geo_adresse, 
        T.siret, 
        T.trancheeffectifsetablissement as tranche_effectif_salarie, 
        N.tranche_effectif_salarie_entreprise, 
        T.typevoieetablissement as type_voie, 
        T.complementadresseetablissement as complement_adresse,
        T.codecommuneetablissement as commune, 
        T.libellecommuneetrangeretablissement as commune_etranger,
        T.codepaysetrangeretablissement as code_pays_etranger,
        T.libellepaysetrangeretablissement as libelle_pays_etranger,
        T.etatadministratifetablissement as etat_administratif_etablissement,
        N.economieSocialeSolidaireUniteLegale,
        N.identifiantAssociationUniteLegale,
        N.nom_complet,
        N.nom_url,
        N.numero_tva_intra,
        T.tsv,
        N.tsv_nomentreprise,
        N.tsv_nomprenom,
        T.tsv_adresse,
        N.tsv_enseigne
    FROM siret T 
    LEFT JOIN siren_full N 
    ON N.siren = T.siren;
;



CREATE OR REPLACE FUNCTION get_unite_legale (search text, page_ask text, per_page_ask text) 
returns table (
    unite_legale jsonb,
    total_results bigint,
    total_pages integer,
    page integer,
    per_page integer
) 
language plpgsql
as $$
DECLARE 
    totalcountnomul INTEGER := (SELECT COUNT(*) FROM (SELECT * FROM siren_full WHERE tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) LIMIT 2000) tbl);
    totalcount INTEGER;
    offsetNb INTEGER := (SELECT ((CAST (page_ask AS INTEGER) - 1)*(CAST (per_page_ask AS INTEGER))));
BEGIN
    IF (totalcountnomul < 2000) THEN
        totalcount := (SELECT COUNT(*) FROM (SELECT * FROM siren_full WHERE tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) LIMIT 2000) tbl);
        IF (totalcount < 2000) THEN
            return query 
                SELECT 
                        jsonb_agg(
                            json_build_object(
                                'activite_principale', t.activite_principale,
                                'activite_principale_entreprise', t.activite_principale_entreprise,
                                'activite_principale_registre_metier', t.activite_principale_registre_metier,
                                'statut_unite_legale', t.statut_unite_legale,
                                'categorie_entreprise', t.categorie_entreprise,
                                'cedex', t.cedex,
                                'code_postal', t.code_postal,
                                'date_creation', t.date_creation,
                                'date_creation_entreprise', t.date_creation_entreprise,
                                'date_debut_activite', t.date_debut_activite,
                                'date_mise_a_jour', t.date_mise_a_jour,
                                'enseigne', t.enseigne,
                                'geo_adresse', t.geo_adresse,
                                'geo_id', t.geo_id,
                                'geo_l4', t.geo_l4,
                                'geo_l5', t.geo_l5,
                                'geo_ligne', t.geo_ligne,
                                'geo_score', t.geo_score,
                                'geo_type', t.geo_type,
                                'is_siege', t.is_siege,
                                'latitude', t.latitude,
                                'libelle_commune', t.libelle_commune,
                                'libelle_voie', t.libelle_voie,
                                'indice_repetition', t.indice_repetition,
                                'longitude', t.longitude,
                                'nature_juridique_entreprise', t.nature_juridique_entreprise,
                                'nic', t.nic,
                                'nic_siege', t.nic_siege,
                                'nom', t.nom,
                                'nom_raison_sociale', t.nom_raison_sociale,
                                'numero_voie', t.numero_voie,
                                'prenom', t.prenom,
                                'sexe', t.sexe,
                                'sigle', t.sigle,
                                'siren', t.siren,
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'tsv', t.tsv,
                                'etablissements', t.etablissements,
                                'nombre_etablissements', t.nombre_etablissements,
                                'score', t.score,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement,
                                'nom_complet', t.nom_complet,
                                'nom_url', t.nom_url,
                                'numero_tva_intra', t.numero_tva_intra,
                                'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                                'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                            )
                        ) as unite_legale,
                        min(t.rowcount) as total_results,
                        CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                        CAST (page_ask AS INTEGER) as page,
                        CAST (per_page_ask AS INTEGER) as per_page
                FROM 
                    (
                        SELECT
                            COUNT(*) OVER () as rowcount,
                            ts_rank(tsv,to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')),1) as score,
                            activite_principale, 
                            activite_principale_entreprise, 
                            activite_principale_registre_metier, 
                            statut_unite_legale,
                            categorie_entreprise, 
                            cedex, 
                            code_postal, 
                            date_creation, 
                            date_creation_entreprise, 
                            date_debut_activite, 
                            date_mise_a_jour, 
                            enseigne, 
                            geo_adresse, 
                            geo_id, 
                            geo_l4, 
                            geo_l5, 
                            geo_ligne, 
                            geo_score, 
                            geo_type, 
                            is_siege, 
                            latitude, 
                            libelle_commune, 
                            libelle_voie, 
                            indice_repetition,
                            longitude, 
                            nature_juridique_entreprise, 
                            nic, 
                            nic_siege, 
                            nom, 
                            nom_raison_sociale, 
                            numero_voie, 
                            prenom, 
                            sexe,
                            sigle, 
                            siren, 
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            tsv,
                            etablissements,
                            nombre_etablissements,
                            etat_administratif_etablissement,
                            nom_complet,
                            nom_url,
                            numero_tva_intra,
                            economieSocialeSolidaireUniteLegale,
                            identifiantAssociationUniteLegale
                        FROM
                            siren_full 
                        WHERE 
                            tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        ORDER BY 
                            etat_administratif_etablissement, 
                            (CASE WHEN tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            score DESC, 
                            nombre_etablissements DESC,
                            (CASE WHEN tsv_nomprenom @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            (CASE WHEN tsv_enseigne @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            (CASE WHEN tsv_adresse @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END)
                        OFFSET offsetNb
                        LIMIT CAST (per_page_ask AS INTEGER)
                    ) t;        
        ELSE
            return query
            SELECT 
                        jsonb_agg(
                            json_build_object(
                                'activite_principale', t.activite_principale,
                                'activite_principale_entreprise', t.activite_principale_entreprise,
                                'activite_principale_registre_metier', t.activite_principale_registre_metier,
                                'statut_unite_legale', t.statut_unite_legale,
                                'categorie_entreprise', t.categorie_entreprise,
                                'cedex', t.cedex,
                                'code_postal', t.code_postal,
                                'date_creation', t.date_creation,
                                'date_creation_entreprise', t.date_creation_entreprise,
                                'date_debut_activite', t.date_debut_activite,
                                'date_mise_a_jour', t.date_mise_a_jour,
                                'enseigne', t.enseigne,
                                'geo_adresse', t.geo_adresse,
                                'geo_id', t.geo_id,
                                'geo_l4', t.geo_l4,
                                'geo_l5', t.geo_l5,
                                'geo_ligne', t.geo_ligne,
                                'geo_score', t.geo_score,
                                'geo_type', t.geo_type,
                                'is_siege', t.is_siege,
                                'latitude', t.latitude,
                                'libelle_commune', t.libelle_commune,
                                'libelle_voie', t.libelle_voie,
                                'indice_repetition', t.indice_repetition,
                                'longitude', t.longitude,
                                'nature_juridique_entreprise', t.nature_juridique_entreprise,
                                'nic', t.nic,
                                'nic_siege', t.nic_siege,
                                'nom', t.nom,
                                'nom_raison_sociale', t.nom_raison_sociale,
                                'numero_voie', t.numero_voie,
                                'prenom', t.prenom,
                                'sexe', t.sexe,
                                'sigle', t.sigle,
                                'siren', t.siren,
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'tsv', t.tsv,
                                'etablissements', t.etablissements,
                                'nombre_etablissements', t.nombre_etablissements,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement,
                                'nom_complet',t.nom_complet,
                                'nom_url', t.nom_url,
                                'numero_tva_intra', t.numero_tva_intra,
                                'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                                'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                            )
                        ) as unite_legale,
                        min(t.rowcount) as total_results,
                        CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                        CAST (page_ask AS INTEGER) as page,
                        CAST (per_page_ask AS INTEGER) as per_page
                FROM 
                    (
                        SELECT
                            CAST(2000 AS BIGINT) as rowcount,
                            activite_principale, 
                            activite_principale_entreprise, 
                            activite_principale_registre_metier, 
                            statut_unite_legale,
                            categorie_entreprise, 
                            cedex, 
                            code_postal, 
                            date_creation, 
                            date_creation_entreprise, 
                            date_debut_activite, 
                            date_mise_a_jour, 
                            enseigne, 
                            geo_adresse, 
                            geo_id, 
                            geo_l4, 
                            geo_l5, 
                            geo_ligne, 
                            geo_score, 
                            geo_type, 
                            is_siege, 
                            latitude, 
                            libelle_commune, 
                            libelle_voie, 
                            indice_repetition,
                            longitude, 
                            nature_juridique_entreprise, 
                            nic, 
                            nic_siege, 
                            nom, 
                            nom_raison_sociale, 
                            numero_voie, 
                            prenom, 
                            sexe,
                            sigle, 
                            siren, 
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            tsv,
                            etablissements,
                            nombre_etablissements,
                            etat_administratif_etablissement,
                            nom_complet,
                            nom_url,
                            numero_tva_intra,
                            economieSocialeSolidaireUniteLegale,
                            identifiantAssociationUniteLegale
                        FROM
                            siren_full 
                        WHERE 
                            tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        ORDER BY
                            etat_administratif_etablissement,
                            nombre_etablissements DESC
                        OFFSET offsetNb
                        LIMIT CAST (per_page_ask AS INTEGER)
                    ) t;   
        END IF; 
                
    ELSE
        return query
        SELECT 
                    jsonb_agg(
                        json_build_object(
                            'activite_principale', t.activite_principale,
                            'activite_principale_entreprise', t.activite_principale_entreprise,
                            'activite_principale_registre_metier', t.activite_principale_registre_metier,
                            'statut_unite_legale', t.statut_unite_legale,
                            'categorie_entreprise', t.categorie_entreprise,
                            'cedex', t.cedex,
                            'code_postal', t.code_postal,
                            'date_creation', t.date_creation,
                            'date_creation_entreprise', t.date_creation_entreprise,
                            'date_debut_activite', t.date_debut_activite,
                            'date_mise_a_jour', t.date_mise_a_jour,
                            'enseigne', t.enseigne,
                            'geo_adresse', t.geo_adresse,
                            'geo_id', t.geo_id,
                            'geo_l4', t.geo_l4,
                            'geo_l5', t.geo_l5,
                            'geo_ligne', t.geo_ligne,
                            'geo_score', t.geo_score,
                            'geo_type', t.geo_type,
                            'is_siege', t.is_siege,
                            'latitude', t.latitude,
                            'libelle_commune', t.libelle_commune,
                            'libelle_voie', t.libelle_voie,
                            'indice_repetition', t.indice_repetition,
                            'longitude', t.longitude,
                            'nature_juridique_entreprise', t.nature_juridique_entreprise,
                            'nic', t.nic,
                            'nic_siege', t.nic_siege,
                            'nom', t.nom,
                            'nom_raison_sociale', t.nom_raison_sociale,
                            'numero_voie', t.numero_voie,
                            'prenom', t.prenom,
                            'sexe', t.sexe,
                            'sigle', t.sigle,
                            'siren', t.siren,
                            'siret', t.siret,
                            'tranche_effectif_salarie', t.tranche_effectif_salarie,
                            'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                            'type_voie', t.type_voie,
                            'commune', t.commune,
                            'tsv', t.tsv,
                            'etablissements', t.etablissements,
                            'nombre_etablissements', t.nombre_etablissements,
                            'etat_administratif_etablissement', t.etat_administratif_etablissement,
                            'nom_complet',t.nom_complet,
                            'nom_url', t.nom_url,
                            'numero_tva_intra', t.numero_tva_intra,
                            'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                            'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                        )
                    ) as unite_legale,
                    min(t.rowcount) as total_results,
                    CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                    CAST (page_ask AS INTEGER) as page,
                    CAST (per_page_ask AS INTEGER) as per_page
            FROM 
                (
                    SELECT
                        CAST(2000 AS BIGINT) as rowcount,
                        activite_principale, 
                        activite_principale_entreprise, 
                        activite_principale_registre_metier, 
                        statut_unite_legale,
                        categorie_entreprise, 
                        cedex, 
                        code_postal, 
                        date_creation, 
                        date_creation_entreprise, 
                        date_debut_activite, 
                        date_mise_a_jour, 
                        enseigne, 
                        geo_adresse, 
                        geo_id, 
                        geo_l4, 
                        geo_l5, 
                        geo_ligne, 
                        geo_score, 
                        geo_type, 
                        is_siege, 
                        latitude, 
                        libelle_commune, 
                        libelle_voie, 
                        indice_repetition,
                        longitude, 
                        nature_juridique_entreprise, 
                        nic, 
                        nic_siege, 
                        nom, 
                        nom_raison_sociale, 
                        numero_voie, 
                        prenom, 
                        sexe,
                        sigle, 
                        siren, 
                        siret, 
                        tranche_effectif_salarie, 
                        tranche_effectif_salarie_entreprise, 
                        type_voie, 
                        commune, 
                        tsv,
                        etablissements,
                        nombre_etablissements,
                        etat_administratif_etablissement,
                        nom_complet,
                        nom_url,
                        numero_tva_intra,
                        economieSocialeSolidaireUniteLegale,
                        identifiantAssociationUniteLegale
                    FROM
                        siren_full 
                    WHERE 
                        tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                    OFFSET offsetNb
                    LIMIT CAST (per_page_ask AS INTEGER)
                ) t;   
    END IF;
end;$$;;



CREATE OR REPLACE FUNCTION get_etablissement_fts (search text, page_ask text, per_page_ask text) 
returns table (
    etablissement jsonb,
    total_results bigint,
    total_pages integer,
    page integer,
    per_page integer
) 
language plpgsql
as $$
DECLARE 
    totalcountnomul INTEGER := (SELECT COUNT(*) FROM (SELECT * FROM etablissements_view WHERE etat_administratif_etablissement =  'A' AND tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) LIMIT 2000) tbl);
    totalcount INTEGER;
    offsetNb INTEGER := (SELECT ((CAST (page_ask AS INTEGER) - 1)*(CAST (per_page_ask AS INTEGER))));
BEGIN
    IF (totalcountnomul < 2000) THEN -- Less than 2000 distinct companies
        totalcount := (SELECT COUNT(*) FROM (SELECT * FROM etablissements_view WHERE etat_administratif_etablissement = 'A' AND tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) LIMIT 2000) tbl);
        IF (totalcount < 2000) THEN -- Less than 2000 buildings, do a pertinence search
            return query 
                SELECT 
                        jsonb_agg(
                            json_build_object(
                                'activite_principale', t.activite_principale,
                                'nomenclature_activite_principale_etablissement', t.nomenclature_activite_principale_etablissement,
                                'activite_principale_entreprise', t.activite_principale_entreprise,
                                'activite_principale_registre_metier', t.activite_principale_registre_metier,
                                -- 'statut_unite_legale', t.statut_unite_legale,
                                'categorie_entreprise', t.categorie_entreprise,
                                'cedex', t.cedex,
                                'code_postal', t.code_postal,
                                'date_creation', t.date_creation,
                                'date_creation_entreprise', t.date_creation_entreprise,
                                'date_debut_activite', t.date_debut_activite,
                                'date_mise_a_jour', t.date_mise_a_jour,
                                'enseigne', t.enseigne,
                                'geo_adresse', t.geo_adresse,
                                'geo_id', t.geo_id,
                                'geo_l4', t.geo_l4,
                                'geo_l5', t.geo_l5,
                                'geo_ligne', t.geo_ligne,
                                'geo_score', t.geo_score,
                                'geo_type', t.geo_type,
                                'is_siege', t.is_siege,
                                'latitude', t.latitude,
                                'libelle_commune', t.libelle_commune,
                                'libelle_voie', t.libelle_voie,
                                'indice_repetition', t.indice_repetition,
                                'longitude', t.longitude,
                                'nature_juridique_entreprise', t.nature_juridique_entreprise,
                                'nic', t.nic,
                                'nic_siege', t.nic_siege,
                                'nom', t.nom,
                                'nom_raison_sociale', t.nom_raison_sociale,
                                'numero_voie', t.numero_voie,
                                'prenom', t.prenom,
                                'sexe', t.sexe,
                                'sigle', t.sigle,
                                'siren', t.siren,
                                'siege_geo_adresse', t.siege_geo_adresse,
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'complement_adresse', t.complement_adresse,
                                'commune_etranger', t.commune_etranger,
                                'code_pays_etranger', t.code_pays_etranger,
                                'libelle_pays_etranger', t.libelle_pays_etranger,
                                'tsv', t.tsv,
                                -- 'etablissements', t.etablissements,
                                -- 'nombre_etablissements', t.nombre_etablissements,
                                'score', t.score,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement,
                                -- 'nom_complet', t.nom_complet,
                                -- 'nom_url', t.nom_url,
                                'numero_tva_intra', t.numero_tva_intra
                                -- 'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                                -- 'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                            )
                        ) as etablissement,
                        min(t.rowcount) as total_results,
                        CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                        CAST (page_ask AS INTEGER) as page,
                        CAST (per_page_ask AS INTEGER) as per_page
                FROM 
                    (
                        SELECT
                            COUNT(*) OVER () as rowcount,
                            ts_rank(tsv,to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')),1) as score,
                            activite_principale, 
                            nomenclature_activite_principale_etablissement,
                            activite_principale_entreprise, 
                            activite_principale_registre_metier, 
                            -- statut_unite_legale,
                            categorie_entreprise, 
                            cedex, 
                            code_postal, 
                            date_creation, 
                            date_creation_entreprise, 
                            date_debut_activite, 
                            date_mise_a_jour, 
                            enseigne, 
                            geo_adresse, 
                            geo_id, 
                            geo_l4, 
                            geo_l5, 
                            geo_ligne, 
                            geo_score, 
                            geo_type, 
                            is_siege, 
                            latitude, 
                            libelle_commune, 
                            libelle_voie, 
                            indice_repetition,
                            longitude, 
                            nature_juridique_entreprise, 
                            nic, 
                            nic_siege, 
                            nom, 
                            nom_raison_sociale, 
                            numero_voie, 
                            prenom, 
                            sexe,
                            sigle, 
                            siren, 
                            siege_geo_adresse,
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            complement_adresse,
                            commune_etranger,
                            code_pays_etranger,
                            libelle_pays_etranger,
                            tsv,
                            -- etablissements,
                            -- nombre_etablissements,
                            etat_administratif_etablissement,
                            -- nom_complet,
                            -- nom_url,
                            numero_tva_intra
                            -- economieSocialeSolidaireUniteLegale,
                            -- identifiantAssociationUniteLegale
                        FROM
                            etablissements_view 
                        WHERE 
                            etat_administratif_etablissement='A'
                            AND tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        ORDER BY 
                            (CASE WHEN tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            score DESC, 
                            -- nombre_etablissements DESC,
                            (CASE WHEN tsv_nomprenom @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            (CASE WHEN tsv_enseigne @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            (CASE WHEN tsv_adresse @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END)
                        OFFSET offsetNb
                        LIMIT CAST (per_page_ask AS INTEGER)
                    ) t;        
        ELSE -- More than 2000 results don t order by pertinence
            return query
            SELECT 
                        jsonb_agg(
                            json_build_object(
                                'activite_principale', t.activite_principale,
                                'nomenclature_activite_principale_etablissement', t.nomenclature_activite_principale_etablissement,
                                'activite_principale_entreprise', t.activite_principale_entreprise,
                                'activite_principale_registre_metier', t.activite_principale_registre_metier,
                                -- 'statut_unite_legale', t.statut_unite_legale,
                                'categorie_entreprise', t.categorie_entreprise,
                                'cedex', t.cedex,
                                'code_postal', t.code_postal,
                                'date_creation', t.date_creation,
                                'date_creation_entreprise', t.date_creation_entreprise,
                                'date_debut_activite', t.date_debut_activite,
                                'date_mise_a_jour', t.date_mise_a_jour,
                                'enseigne', t.enseigne,
                                'geo_adresse', t.geo_adresse,
                                'geo_id', t.geo_id,
                                'geo_l4', t.geo_l4,
                                'geo_l5', t.geo_l5,
                                'geo_ligne', t.geo_ligne,
                                'geo_score', t.geo_score,
                                'geo_type', t.geo_type,
                                'is_siege', t.is_siege,
                                'latitude', t.latitude,
                                'libelle_commune', t.libelle_commune,
                                'libelle_voie', t.libelle_voie,
                                'indice_repetition', t.indice_repetition,
                                'longitude', t.longitude,
                                'nature_juridique_entreprise', t.nature_juridique_entreprise,
                                'nic', t.nic,
                                'nic_siege', t.nic_siege,
                                'nom', t.nom,
                                'nom_raison_sociale', t.nom_raison_sociale,
                                'numero_voie', t.numero_voie,
                                'prenom', t.prenom,
                                'sexe', t.sexe,
                                'sigle', t.sigle,
                                'siren', t.siren,
                                'siege_geo_adresse', t.siege_geo_adresse,
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'complement_adresse', t.complement_adresse,
                                'commune_etranger', t.commune_etranger,
                                'code_pays_etranger', t.code_pays_etranger,
                                'libelle_pays_etranger', t.libelle_pays_etranger,
                                'tsv', t.tsv,
                                -- 'etablissements', t.etablissements,
                                -- 'nombre_etablissements', t.nombre_etablissements,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement,
                                -- 'nom_complet',t.nom_complet,
                                -- 'nom_url', t.nom_url,
                                'numero_tva_intra', t.numero_tva_intra
                                -- 'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                                -- 'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                            )
                        ) as etablissement,
                        min(t.rowcount) as total_results,
                        CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                        CAST (page_ask AS INTEGER) as page,
                        CAST (per_page_ask AS INTEGER) as per_page
                FROM 
                    (
                        SELECT
                            CAST(2000 AS BIGINT) as rowcount,
                            activite_principale, 
                            nomenclature_activite_principale_etablissement,
                            activite_principale_entreprise, 
                            activite_principale_registre_metier, 
                            -- statut_unite_legale,
                            categorie_entreprise, 
                            cedex, 
                            code_postal, 
                            date_creation, 
                            date_creation_entreprise, 
                            date_debut_activite, 
                            date_mise_a_jour, 
                            enseigne, 
                            geo_adresse, 
                            geo_id, 
                            geo_l4, 
                            geo_l5, 
                            geo_ligne, 
                            geo_score, 
                            geo_type, 
                            is_siege, 
                            latitude, 
                            libelle_commune, 
                            libelle_voie, 
                            indice_repetition,
                            longitude, 
                            nature_juridique_entreprise, 
                            nic, 
                            nic_siege, 
                            nom, 
                            nom_raison_sociale, 
                            numero_voie, 
                            prenom, 
                            sexe,
                            sigle, 
                            siren, 
                            siege_geo_adresse,
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            complement_adresse,
                            commune_etranger,
                            code_pays_etranger,
                            libelle_pays_etranger,
                            tsv,
                            -- etablissements,
                            -- nombre_etablissements,
                            etat_administratif_etablissement,
                            nom_complet,
                            -- nom_url,
                            numero_tva_intra
                            -- economieSocialeSolidaireUniteLegale,
                            -- identifiantAssociationUniteLegale
                        FROM
                            etablissements_view 
                        WHERE 
                            etat_administratif_etablissement = 'A'
                            AND tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        OFFSET offsetNb
                        LIMIT CAST (per_page_ask AS INTEGER)
                    ) t;   
        END IF; 
                
    ELSE -- More than 2000 companies, don t perform pertinence ordering 
        return query
        SELECT 
                    jsonb_agg(
                        json_build_object(
                            'activite_principale', t.activite_principale,
                            'nomenclature_activite_principale_etablissement', t.nomenclature_activite_principale_etablissement,
                            'activite_principale_entreprise', t.activite_principale_entreprise,
                            'activite_principale_registre_metier', t.activite_principale_registre_metier,
                            -- 'statut_unite_legale', t.statut_unite_legale,
                            'categorie_entreprise', t.categorie_entreprise,
                            'cedex', t.cedex,
                            'code_postal', t.code_postal,
                            'date_creation', t.date_creation,
                            'date_creation_entreprise', t.date_creation_entreprise,
                            'date_debut_activite', t.date_debut_activite,
                            'date_mise_a_jour', t.date_mise_a_jour,
                            'enseigne', t.enseigne,
                            'geo_adresse', t.geo_adresse,
                            'geo_id', t.geo_id,
                            'geo_l4', t.geo_l4,
                            'geo_l5', t.geo_l5,
                            'geo_ligne', t.geo_ligne,
                            'geo_score', t.geo_score,
                            'geo_type', t.geo_type,
                            'is_siege', t.is_siege,
                            'latitude', t.latitude,
                            'libelle_commune', t.libelle_commune,
                            'libelle_voie', t.libelle_voie,
                            'indice_repetition', t.indice_repetition,
                            'longitude', t.longitude,
                            'nature_juridique_entreprise', t.nature_juridique_entreprise,
                            'nic', t.nic,
                            'nic_siege', t.nic_siege,
                            'nom', t.nom,
                            'nom_raison_sociale', t.nom_raison_sociale,
                            'numero_voie', t.numero_voie,
                            'prenom', t.prenom,
                            'sexe', t.sexe,
                            'sigle', t.sigle,
                            'siren', t.siren,
                            'siege_geo_adresse', t.siege_geo_adresse,
                            'siret', t.siret,
                            'tranche_effectif_salarie', t.tranche_effectif_salarie,
                            'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                            'type_voie', t.type_voie,
                            'commune', t.commune,
                            'complement_adresse', t.complement_adresse,
                            'commune_etranger', t.commune_etranger,
                            'code_pays_etranger', t.code_pays_etranger,
                            'libelle_pays_etranger', t.libelle_pays_etranger,
                            'tsv', t.tsv,
                            -- 'etablissements', t.etablissements,
                            -- 'nombre_etablissements', t.nombre_etablissements,
                            'etat_administratif_etablissement', t.etat_administratif_etablissement
                            -- 'nom_complet',t.nom_complet,
                            -- 'nom_url', t.nom_url,
                            'numero_tva_intra', t.numero_tva_intra
                            -- 'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                            -- 'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                        )
                    ) as etablissement,
                    min(t.rowcount) as total_results,
                    CAST (ROUND(((min(t.rowcount)+(CAST (per_page_ask AS INTEGER))-1)/(CAST (per_page_ask AS INTEGER)))) AS INTEGER) as total_pages, 
                    CAST (page_ask AS INTEGER) as page,
                    CAST (per_page_ask AS INTEGER) as per_page
            FROM 
                (
                    SELECT
                        CAST(2000 AS BIGINT) as rowcount,
                        activite_principale, 
                        nomenclature_activite_principale_etablissement,
                        activite_principale_entreprise, 
                        activite_principale_registre_metier, 
                        -- statut_unite_legale,
                        categorie_entreprise, 
                        cedex, 
                        code_postal, 
                        date_creation, 
                        date_creation_entreprise, 
                        date_debut_activite, 
                        date_mise_a_jour, 
                        enseigne, 
                        geo_adresse, 
                        geo_id, 
                        geo_l4, 
                        geo_l5, 
                        geo_ligne, 
                        geo_score, 
                        geo_type, 
                        is_siege, 
                        latitude, 
                        libelle_commune, 
                        libelle_voie, 
                        indice_repetition,
                        longitude, 
                        nature_juridique_entreprise, 
                        nic, 
                        nic_siege, 
                        nom, 
                        nom_raison_sociale, 
                        numero_voie, 
                        prenom, 
                        sexe,
                        sigle, 
                        siren, 
                        siege_geo_adresse,
                        siret, 
                        tranche_effectif_salarie, 
                        tranche_effectif_salarie_entreprise, 
                        type_voie, 
                        commune, 
                        complement_adresse,
                        commune_etranger,
                        code_pays_etranger,
                        libelle_pays_etranger,
                        tsv,
                        -- etablissements,
                        -- nombre_etablissements,
                        etat_administratif_etablissement,
                        -- nom_complet,
                        -- nom_url,
                        numero_tva_intra
                        -- economieSocialeSolidaireUniteLegale,
                        -- identifiantAssociationUniteLegale
                    FROM
                        etablissements_view 
                    WHERE 
                        etat_administratif_etablissement = 'A'
                        AND tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                    OFFSET offsetNb
                    LIMIT CAST (per_page_ask AS INTEGER)
                ) t;   
    END IF;
end;$$;


CREATE OR REPLACE FUNCTION get_etablissements (siren_search text, page_ask text) 
returns table (
    unite_legale jsonb
) 
language plpgsql
as $$ 
DECLARE 
    nbent INTEGER := (SELECT nombre_etablissements FROM siren_full WHERE siren = siren_search);
    maxent INTEGER := 200;
BEGIN
    IF (nbent < maxent) THEN
        return query 
            SELECT 
                    jsonb_agg(
                        json_build_object(
                            'activite_principale', t.activite_principale,
                            'activite_principale_entreprise', t.activite_principale_entreprise,
                            'activite_principale_registre_metier', t.activite_principale_registre_metier,
                            'categorie_entreprise', t.categorie_entreprise,
                            'cedex', t.cedex,
                            'code_postal', t.code_postal,
                            'date_creation', t.date_creation,
                            'date_creation_entreprise', t.date_creation_entreprise,
                            'date_debut_activite', t.date_debut_activite,
                            'date_mise_a_jour', t.date_mise_a_jour,
                            'enseigne', t.enseigne,
                            'geo_adresse', t.geo_adresse,
                            'geo_id', t.geo_id,
                            'geo_l4', t.geo_l4,
                            'geo_l5', t.geo_l5,
                            'geo_ligne', t.geo_ligne,
                            'geo_score', t.geo_score,
                            'geo_type', t.geo_type,
                            'is_siege', t.is_siege,
                            'latitude', t.latitude,
                            'libelle_commune', t.libelle_commune,
                            'libelle_voie', t.libelle_voie,
                            'longitude', t.longitude,
                            'nature_juridique_entreprise', t.nature_juridique_entreprise,
                            'nic', t.nic,
                            'nic_siege', t.nic_siege,
                            'nom', t.nom,
                            'nom_raison_sociale', t.nom_raison_sociale,
                            'numero_voie', t.numero_voie,
                            'prenom', t.prenom,
                            'sexe', t.sexe,
                            'sigle', t.sigle,
                            'siren', t.siren,
                            'siret', t.siret,
                            'tranche_effectif_salarie', t.tranche_effectif_salarie,
                            'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                            'type_voie', t.type_voie,
                            'commune', t.commune,
                            'nombre_etablissements', t.nombre_etablissements,
                            'etat_administratif_etablissement', t.etat_administratif_etablissement,
                            'nom_complet', t.nom_complet,
                            'nom_url', t.nom_url,
                            'etablissements', t.etablissements_array,
                            'etablissement_siege', t.etablissement_siege,
                            'numero_tva_intra', t.numero_tva_intra,
                            'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                            'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                        )
                    ) as unite_legale
            FROM 
                (
                    SELECT
                        ul.*,
                        (SELECT json_agg(t1) FROM (SELECT * from etablissements_view WHERE siren = siren_search ORDER BY is_siege DESC,etat_administratif_etablissement) t1) as etablissements_array,
                        (SELECT json_agg(t2) FROM (SELECT * from etablissements_view WHERE siren = siren_search AND is_siege = 't') t2) as etablissement_siege
                    FROM 
                        siren_full ul
                    WHERE 
                        ul.siren = siren_search
                ) t;    
    ELSE
        return query 
            SELECT 
                    jsonb_agg(
                        json_build_object(
                            'activite_principale', t.activite_principale,
                            'activite_principale_entreprise', t.activite_principale_entreprise,
                            'activite_principale_registre_metier', t.activite_principale_registre_metier,
                            'categorie_entreprise', t.categorie_entreprise,
                            'cedex', t.cedex,
                            'code_postal', t.code_postal,
                            'date_creation', t.date_creation,
                            'date_creation_entreprise', t.date_creation_entreprise,
                            'date_debut_activite', t.date_debut_activite,
                            'date_mise_a_jour', t.date_mise_a_jour,
                            'enseigne', t.enseigne,
                            'geo_adresse', t.geo_adresse,
                            'geo_id', t.geo_id,
                            'geo_l4', t.geo_l4,
                            'geo_l5', t.geo_l5,
                            'geo_ligne', t.geo_ligne,
                            'geo_score', t.geo_score,
                            'geo_type', t.geo_type,
                            'is_siege', t.is_siege,
                            'latitude', t.latitude,
                            'libelle_commune', t.libelle_commune,
                            'libelle_voie', t.libelle_voie,
                            'longitude', t.longitude,
                            'nature_juridique_entreprise', t.nature_juridique_entreprise,
                            'nic', t.nic,
                            'nic_siege', t.nic_siege,
                            'nom', t.nom,
                            'nom_raison_sociale', t.nom_raison_sociale,
                            'numero_voie', t.numero_voie,
                            'prenom', t.prenom,
                            'sexe', t.sexe,
                            'sigle', t.sigle,
                            'siren', t.siren,
                            'siret', t.siret,
                            'tranche_effectif_salarie', t.tranche_effectif_salarie,
                            'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                            'type_voie', t.type_voie,
                            'commune', t.commune,
                            'nombre_etablissements', t.nombre_etablissements,
                            'etat_administratif_etablissement', t.etat_administratif_etablissement,
                            'nom_complet', t.nom_complet,
                            'nom_url', t.nom_url,
                            'etablissements', t.etablissements_array,
                            'etablissement_siege', t.etablissement_siege,
                            'numero_tva_intra', t.numero_tva_intra,
                            'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                            'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                        )
                    ) as unite_legale
            FROM 
                (
                    SELECT
                        ul.*,
                        (SELECT json_agg(t1) FROM (SELECT * from etablissements_view WHERE siren = siren_search LIMIT maxent OFFSET (CAST(page_ask AS INTEGER)-1)*maxent) t1) as etablissements_array,
                        (SELECT json_agg(t2) FROM (SELECT * from etablissements_view WHERE siren = siren_search AND is_siege = 't') t2) as etablissement_siege
                    FROM 
                        siren_full ul
                    WHERE 
                        ul.siren = siren_search
                ) t;   
    END IF;
end;$$;;



CREATE OR REPLACE FUNCTION get_etablissement (siret_search text) 
returns table (
    etablissement jsonb
) 
language plpgsql
as $$ 
BEGIN
    return query 
        SELECT 
                jsonb_agg(
                    json_build_object(

                    'activite_principale', t.activite_principale, 
                    'activite_principale_entreprise', t.activite_principale_entreprise, 
                    'activite_principale_registre_metier', t.activite_principale_registre_metier, 
                    'categorie_entreprise', t.categorie_entreprise, 
                    'cedex', t.cedex, 
                    'code_postal', t.code_postal, 
                    'date_creation', t.date_creation, 
                    'date_creation_entreprise', t.date_creation_entreprise, 
                    'date_debut_activite', t.date_debut_activite, 
                    'date_mise_a_jour', t.date_mise_a_jour, 
                    'enseigne', t.enseigne, 
                    'geo_adresse', t.geo_adresse, 
                    'geo_id', t.geo_id, 
                    'geo_l4', t.geo_l4, 
                    'geo_l5', t.geo_l5, 
                    'geo_ligne', t.geo_ligne, 
                    'geo_score', t.geo_score, 
                    'geo_type', t.geo_type, 
                    'is_siege', t.is_siege, 
                    'latitude', t.latitude, 
                    'libelle_commune', t.libelle_commune, 
                    'libelle_voie', t.libelle_voie, 
                    'indice_repetition', t.indice_repetition,
                    'longitude', t.longitude, 
                    'nature_juridique_entreprise', t.nature_juridique_entreprise, 
                    'nic', t.nic, 
                    'nic_siege', t.nic_siege, 
                    'nom', t.nom, 
                    'nom_raison_sociale', t.nom_raison_sociale, 
                    'numero_voie', t.numero_voie, 
                    'prenom', t.prenom, 
                    'sexe', t.sexe,
                    'sigle', t.sigle, 
                    'siren', t.siren, 
                    'siege_geo_adresse', t.siege_geo_adresse,
                    'siret', t.siret, 
                    'tranche_effectif_salarie', t.tranche_effectif_salarie, 
                    'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise, 
                    'type_voie', t.type_voie, 
                    'commune', t.commune, 
                    'complement_adresse', t.complement_adresse,
                    'commune_etranger', t.commune_etranger,
                    'code_pays_etranger', t.code_pays_etranger,
                    'libelle_pays_etranger', t.libelle_pays_etranger,
                    'numero_tva_intra', t.numero_tva_intra,
                    'etat_administratif_etablissement', t.etat_administratif_etablissement,
                    'unite_legale', t.unite_legale,
                    'economieSocialeSolidaireUniteLegale', t.economieSocialeSolidaireUniteLegale,
                    'identifiantAssociationUniteLegale', t.identifiantAssociationUniteLegale
                    )
                ) as etablissement
        FROM 
            (
                SELECT
                    ev.*,
                    (SELECT * FROM get_etablissements(ev.siren, '1') t1) as unite_legale
                FROM 
                    etablissements_view ev
                WHERE 
                    ev.siret = siret_search
            ) t;        
end;$$;;