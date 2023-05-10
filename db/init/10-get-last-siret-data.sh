for d in `seq -w 1 19` 2A 2B `seq 21 74` `seq 76 95` 98 ""; do
  cd /var/lib/postgresql/files && wget https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "File geo_siret_$d downloaded"
  else
    echo "Error with download : geo_siret_$d" >&2
    exit 1
  fi
  gunzip /var/lib/postgresql/files/geo_siret_$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "Unzip geo_siret_$d OK"
  else
    echo "Error with Unzip : geo_siret_$d" >&2
    exit 1
  fi

done

#Cas particulier Paris
for d in `seq -w 1 20`; do
  cd /var/lib/postgresql/files && wget https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_751$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "File geo_siret_751$d downloaded"
  else
    echo "Error with download : geo_siret_751$d" >&2
    exit 1
  fi
  gunzip /var/lib/postgresql/files/geo_siret_751$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "Unzip geo_siret_751$d OK"
  else
    echo "Error with Unzip : geo_siret_751$d" >&2
    exit 1
  fi
done
#Cas particulier DOM
for d in `seq -w 1 8`; do
  cd /var/lib/postgresql/files && wget https://files.data.gouv.fr/geo-sirene/last/dep/geo_siret_97$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "File geo_siret_97$d downloaded"
  else
    echo "Error with download : geo_siret_97$d" >&2
    exit 1
  fi
  gunzip /var/lib/postgresql/files/geo_siret_97$d.csv.gz
  if [ $? -eq 0 ];
  then
    echo "Unzip geo_siret_97$d OK"
  else
    echo "Error with Unzip : geo_siret_97$d" >&2
    exit 1
  fi
done