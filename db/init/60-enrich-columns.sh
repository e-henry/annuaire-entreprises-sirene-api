psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN enseignes TEXT;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN tsv tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN tsv_nomentreprise tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN tsv_nomprenom tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN tsv_enseigne tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN tsv_adresse tsvector;"

# Récupération de toutes les enseignes
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET enseignes = (SELECT STRING_AGG(enseignes,', ') AS enseignes FROM (select DISTINCT ST.enseigne1etablissement as enseignes from siret ST where ST.siren = S.siren AND ST.enseigne1etablissement IS NOT NULL) tbl);"

# TSV nom entreprise
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S
SET tsv_nomentreprise = 
setweight(to_tsvector(coalesce(sigleUniteLegale,'')), 'A') || 
setweight(to_tsvector(coalesce(denominationUniteLegale,'')), 'B');"

# TSV nom prenom
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S
SET tsv_nomprenom = 
setweight(to_tsvector(coalesce(nomUniteLegale,'')), 'A') || 
setweight(to_tsvector(coalesce(prenom1UniteLegale,'')), 'A');"

# TSV des enseignes
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren
SET tsv_enseigne = 
setweight(to_tsvector(coalesce(enseignes,'')), 'A');"

# TSV des adresses
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S
SET tsv_adresse = 
setweight(to_tsvector(coalesce(intermediary_view.numero_voie,'')), 'A') ||
setweight(to_tsvector(coalesce(intermediary_view.type_voie,'')), 'A') ||
setweight(to_tsvector(coalesce(intermediary_view.libelle_voie,'')), 'A') ||
setweight(to_tsvector(coalesce(intermediary_view.commune,'')), 'A') ||
setweight(to_tsvector(coalesce(intermediary_view.code_postal,'')), 'A') ||
setweight(to_tsvector(coalesce(intermediary_view.libelle_commune,'')), 'A')
FROM intermediary_view  WHERE S.siren = intermediary_view.siren;"

# TSV complet
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S

SET tsv = 
setweight(to_tsvector(coalesce(S.sigleUniteLegale,'')), 'A') || 
setweight(to_tsvector(coalesce(S.denominationUniteLegale,'')), 'B') || 
setweight(to_tsvector(coalesce(S.enseignes,'')), 'C') || 
setweight(to_tsvector(coalesce(S.nomUniteLegale,'')), 'D') || 
setweight(to_tsvector(coalesce(S.prenom1UniteLegale,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.numero_voie,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.type_voie,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.libelle_voie,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.commune,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.code_postal,'')), 'D') ||
setweight(to_tsvector(coalesce(intermediary_view.libelle_commune,'')), 'D') 
FROM intermediary_view WHERE S.siren = intermediary_view.siren;"


psql -U $POSTGRES_USER -d $POSTGRES_DB -c "DROP VIEW IF EXISTS intermediary_view"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN etablissements TEXT;"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET etablissements = (SELECT STRING_AGG (siret, ',') AS etablissements from (SELECT siret FROM siret where siren = S.siren LIMIT 10) tbl);"


psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN nombre_etablissements INTEGER;"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET nombre_etablissements = (SELECT COUNT(*) AS nombre_etablissements from siret where siren = S.siren);"


psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN nom_complet TEXT;"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET nom_complet = (SELECT
    CASE WHEN S.categoriejuridiqueunitelegale = '1000' THEN
        CASE WHEN S.sigleunitelegale IS NOT NULL THEN
            COALESCE(LOWER(S.prenom1unitelegale),'') || COALESCE(' ' || LOWER(S.nomunitelegale),'') || COALESCE(' (' || LOWER(S.sigleunitelegale) || ')','')
        ELSE
            COALESCE(LOWER(S.prenom1unitelegale),'') || COALESCE(' ' || LOWER(S.nomunitelegale),'')
        END
    ELSE
        CASE WHEN S.sigleunitelegale IS NOT NULL THEN
            COALESCE(LOWER(S.denominationunitelegale),'') || COALESCE(LOWER(' (' || S.sigleunitelegale || ')'),'')
        ELSE
            COALESCE(LOWER(S.denominationunitelegale),'')
        END
    END
);"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN nom_url TEXT;"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET nom_url = regexp_replace(nom_complet || '-' || siren, '[^a-zA-Z0-9]+', '-','g');"


psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siren ADD COLUMN numero_tva_intra TEXT;"

psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siren S SET numero_tva_intra = (SELECT CASE WHEN tvanumber < 10 THEN concat('FR0',tvanumber,siren) ELSE CONCAT('FR',tvanumber,siren) END FROM (SELECT (12+(3*bigintsiren)%97)%97 as tvanumber, siren FROM (select CAST (siren as BIGINT) as bigintsiren,siren from siren WHERE siren = S.siren) tbl) tbl2);"

#
# Siret TSV
#

# TSV des adresses
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siret ADD COLUMN tsv tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "ALTER TABLE siret ADD COLUMN tsv_adresse tsvector;"
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siret S
SET tsv_adresse = 
setweight(to_tsvector(coalesce(numerovoieetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(indicerepetitionetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(typevoieetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(libellevoieetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(codepostaletablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(libellecommuneetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(libellecommuneetrangeretablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(distributionspecialeetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(codecommuneetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(codecedexetablissement,'')), 'A') ||
setweight(to_tsvector(coalesce(libellecedexetablissement,'')), 'A')
;"

# TSV général : mix entre siren et adresse de l'établissement
psql -U $POSTGRES_USER -d $POSTGRES_DB -c "UPDATE siret T

SET tsv = 
setweight(to_tsvector(coalesce(N.sigleUniteLegale,'')), 'A') || 
setweight(to_tsvector(coalesce(N.denominationUniteLegale,'')), 'B') || 
setweight(to_tsvector(coalesce(N.enseignes,'')), 'C') || 
setweight(to_tsvector(coalesce(N.nomUniteLegale,'')), 'D') || 
setweight(to_tsvector(coalesce(N.prenom1UniteLegale,'')), 'D') ||


setweight(to_tsvector(coalesce(T.numerovoieetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.indicerepetitionetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.typevoieetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.libellevoieetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.codepostaletablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.libellecommuneetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.libellecommuneetrangeretablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.distributionspecialeetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.codecommuneetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.codecedexetablissement,'')), 'D') ||
setweight(to_tsvector(coalesce(T.libellecedexetablissement,'')), 'D')

FROM siren N 
WHERE N.siren=T.siren;"
