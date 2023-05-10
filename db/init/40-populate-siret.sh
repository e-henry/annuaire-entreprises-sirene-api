
for d in `seq -w 1 19` 2A 2B `seq 21 74` `seq 76 95` 98 ""; do
    
    mkdir -p /var/lib/postgresql/files/40-populate-siret
    
    echo "\copy siret(siren, nic, siret, statutDiffusionEtablissement, dateCreationEtablissement, trancheEffectifsEtablissement, anneeEffectifsEtablissement, activitePrincipaleRegistreMetiersEtablissement, dateDernierTraitementEtablissement, etablissementSiege, nombrePeriodesEtablissement, complementAdresseEtablissement, numeroVoieEtablissement, indiceRepetitionEtablissement, typeVoieEtablissement, libelleVoieEtablissement, codePostalEtablissement, libelleCommuneEtablissement, libelleCommuneEtrangerEtablissement, distributionSpecialeEtablissement, codeCommuneEtablissement, codeCedexEtablissement, libelleCedexEtablissement, codePaysEtrangerEtablissement, libellePaysEtrangerEtablissement, complementAdresse2Etablissement, numeroVoie2Etablissement, indiceRepetition2Etablissement, typeVoie2Etablissement, libelleVoie2Etablissement, codePostal2Etablissement, libelleCommune2Etablissement, libelleCommuneEtranger2Etablissement, distributionSpeciale2Etablissement, codeCommune2Etablissement, codeCedex2Etablissement, libelleCedex2Etablissement, codePaysEtranger2Etablissement, libellePaysEtranger2Etablissement, dateDebut, etatAdministratifEtablissement, enseigne1Etablissement, enseigne2Etablissement, enseigne3Etablissement, denominationUsuelleEtablissement, activitePrincipaleEtablissement, nomenclatureActivitePrincipaleEtablissement, caractereEmployeurEtablissement, longitude, latitude, geo_score, geo_type, geo_adresse, geo_id, geo_ligne, geo_l4, geo_l5) FROM '/var/lib/postgresql/files/geo_siret_"$d".csv' delimiter ',' csv header encoding 'UTF8';" > /var/lib/postgresql/files/40-populate-siret/geo_siret_"$d".sql

    psql --set ON_ERROR_STOP=true -U $POSTGRES_USER -d $POSTGRES_DB -f /var/lib/postgresql/files/40-populate-siret/geo_siret_"$d".sql
    
    echo "POPULATE dep "$d" OK"

done

for d in `seq -w 1 20`; do
    
    mkdir -p /var/lib/postgresql/files/40-populate-siret

    echo "\copy siret(siren, nic, siret, statutDiffusionEtablissement, dateCreationEtablissement, trancheEffectifsEtablissement, anneeEffectifsEtablissement, activitePrincipaleRegistreMetiersEtablissement, dateDernierTraitementEtablissement, etablissementSiege, nombrePeriodesEtablissement, complementAdresseEtablissement, numeroVoieEtablissement, indiceRepetitionEtablissement, typeVoieEtablissement, libelleVoieEtablissement, codePostalEtablissement, libelleCommuneEtablissement, libelleCommuneEtrangerEtablissement, distributionSpecialeEtablissement, codeCommuneEtablissement, codeCedexEtablissement, libelleCedexEtablissement, codePaysEtrangerEtablissement, libellePaysEtrangerEtablissement, complementAdresse2Etablissement, numeroVoie2Etablissement, indiceRepetition2Etablissement, typeVoie2Etablissement, libelleVoie2Etablissement, codePostal2Etablissement, libelleCommune2Etablissement, libelleCommuneEtranger2Etablissement, distributionSpeciale2Etablissement, codeCommune2Etablissement, codeCedex2Etablissement, libelleCedex2Etablissement, codePaysEtranger2Etablissement, libellePaysEtranger2Etablissement, dateDebut, etatAdministratifEtablissement, enseigne1Etablissement, enseigne2Etablissement, enseigne3Etablissement, denominationUsuelleEtablissement, activitePrincipaleEtablissement, nomenclatureActivitePrincipaleEtablissement, caractereEmployeurEtablissement, longitude, latitude, geo_score, geo_type, geo_adresse, geo_id, geo_ligne, geo_l4, geo_l5) FROM '/var/lib/postgresql/files/geo_siret_751"$d".csv' delimiter ',' csv header encoding 'UTF8';" > /var/lib/postgresql/files/40-populate-siret/geo_siret_751"$d".sql

    psql --set ON_ERROR_STOP=true -U $POSTGRES_USER -d $POSTGRES_DB -f /var/lib/postgresql/files/40-populate-siret/geo_siret_751"$d".sql

    echo "POPULATE dep 751"$d" OK"

done

for d in `seq -w 1 8`; do

    mkdir -p /var/lib/postgresql/files/40-populate-siret

    echo "\copy siret(siren, nic, siret, statutDiffusionEtablissement, dateCreationEtablissement, trancheEffectifsEtablissement, anneeEffectifsEtablissement, activitePrincipaleRegistreMetiersEtablissement, dateDernierTraitementEtablissement, etablissementSiege, nombrePeriodesEtablissement, complementAdresseEtablissement, numeroVoieEtablissement, indiceRepetitionEtablissement, typeVoieEtablissement, libelleVoieEtablissement, codePostalEtablissement, libelleCommuneEtablissement, libelleCommuneEtrangerEtablissement, distributionSpecialeEtablissement, codeCommuneEtablissement, codeCedexEtablissement, libelleCedexEtablissement, codePaysEtrangerEtablissement, libellePaysEtrangerEtablissement, complementAdresse2Etablissement, numeroVoie2Etablissement, indiceRepetition2Etablissement, typeVoie2Etablissement, libelleVoie2Etablissement, codePostal2Etablissement, libelleCommune2Etablissement, libelleCommuneEtranger2Etablissement, distributionSpeciale2Etablissement, codeCommune2Etablissement, codeCedex2Etablissement, libelleCedex2Etablissement, codePaysEtranger2Etablissement, libellePaysEtranger2Etablissement, dateDebut, etatAdministratifEtablissement, enseigne1Etablissement, enseigne2Etablissement, enseigne3Etablissement, denominationUsuelleEtablissement, activitePrincipaleEtablissement, nomenclatureActivitePrincipaleEtablissement, caractereEmployeurEtablissement, longitude, latitude, geo_score, geo_type, geo_adresse, geo_id, geo_ligne, geo_l4, geo_l5) FROM '/var/lib/postgresql/files/geo_siret_97"$d".csv' delimiter ',' csv header encoding 'UTF8';" > /var/lib/postgresql/files/40-populate-siret/geo_siret_97"$d".sql


    psql --set ON_ERROR_STOP=true -U $POSTGRES_USER -d $POSTGRES_DB -f /var/lib/postgresql/files/40-populate-siret/geo_siret_97"$d".sql

    echo "POPULATE dep 97"$d" OK"

done

psql --set ON_ERROR_STOP=true -U $POSTGRES_USER -d $POSTGRES_DB -f /docker-entrypoint-initdb.d/sql/40-populate-siret.sql
