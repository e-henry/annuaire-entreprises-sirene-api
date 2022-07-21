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
    IF (totalcountnomul < 2000) THEN
        totalcount := (SELECT COUNT(*) FROM (SELECT * FROM etablissements_view WHERE etat_administratif_etablissement = 'A' AND tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) LIMIT 2000) tbl);
        IF (totalcount < 2000) THEN
            return query 
                SELECT 
                        jsonb_agg(
                            json_build_object(
                                'activite_principale', t.activite_principale,
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
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'tsv', t.tsv,
                                -- 'etablissements', t.etablissements,
                                -- 'nombre_etablissements', t.nombre_etablissements,
                                'score', t.score,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement
                                -- 'nom_complet', t.nom_complet,
                                -- 'nom_url', t.nom_url,
                                -- 'numero_tva_intra', t.numero_tva_intra,
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
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            tsv,
                            -- etablissements,
                            -- nombre_etablissements,
                            etat_administratif_etablissement
                            -- nom_complet,
                            -- nom_url,
                            -- numero_tva_intra,
                            -- economieSocialeSolidaireUniteLegale,
                            -- identifiantAssociationUniteLegale
                        FROM
                            etablissements_view 
                        WHERE 
                            etat_administratif_etablissement='A'
                            AND tsv @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        ORDER BY 
                            etat_administratif_etablissement, 
                            (CASE WHEN tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & ')) THEN FALSE ELSE TRUE END),
                            score DESC, 
                            -- nombre_etablissements DESC,
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
                                'siret', t.siret,
                                'tranche_effectif_salarie', t.tranche_effectif_salarie,
                                'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                                'type_voie', t.type_voie,
                                'commune', t.commune,
                                'tsv', t.tsv,
                                -- 'etablissements', t.etablissements,
                                -- 'nombre_etablissements', t.nombre_etablissements,
                                'etat_administratif_etablissement', t.etat_administratif_etablissement
                                -- 'nom_complet',t.nom_complet,
                                -- 'nom_url', t.nom_url,
                                -- 'numero_tva_intra', t.numero_tva_intra,
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
                            siret, 
                            tranche_effectif_salarie, 
                            tranche_effectif_salarie_entreprise, 
                            type_voie, 
                            commune, 
                            tsv,
                            -- etablissements,
                            -- nombre_etablissements,
                            etat_administratif_etablissement
                            -- nom_complet,
                            -- nom_url,
                            -- numero_tva_intra,
                            -- economieSocialeSolidaireUniteLegale,
                            -- identifiantAssociationUniteLegale
                        FROM
                            etablissements_view 
                        WHERE 
                            etat_administratif_etablissement = 'A'
                            AND tsv_nomentreprise @@ to_tsquery(REPLACE(REPLACE (search, '%20', ' & '),'%27',' & '))
                        ORDER BY
                            etat_administratif_etablissement
                            -- nombre_etablissements DESC
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
                            'siret', t.siret,
                            'tranche_effectif_salarie', t.tranche_effectif_salarie,
                            'tranche_effectif_salarie_entreprise', t.tranche_effectif_salarie_entreprise,
                            'type_voie', t.type_voie,
                            'commune', t.commune,
                            'tsv', t.tsv,
                            -- 'etablissements', t.etablissements,
                            -- 'nombre_etablissements', t.nombre_etablissements,
                            'etat_administratif_etablissement', t.etat_administratif_etablissement
                            -- 'nom_complet',t.nom_complet,
                            -- 'nom_url', t.nom_url,
                            -- 'numero_tva_intra', t.numero_tva_intra,
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
                        siret, 
                        tranche_effectif_salarie, 
                        tranche_effectif_salarie_entreprise, 
                        type_voie, 
                        commune, 
                        tsv,
                        -- etablissements,
                        -- nombre_etablissements,
                        etat_administratif_etablissement
                        -- nom_complet,
                        -- nom_url,
                        -- numero_tva_intra,
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
