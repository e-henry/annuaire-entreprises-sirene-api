mkdir -p /var/lib/postgresql/files
cd /var/lib/postgresql/files && wget -N https://files.data.gouv.fr/insee-sirene/StockUniteLegale_utf8.zip

if [ $? -eq 0 ];
then
  echo "File downloaded"
else
  echo "Error with download" >&2
  exit 1
fi

cd /var/lib/postgresql/files && unzip -o StockUniteLegale_utf8.zip

if [ $? -eq 0 ];
then
  echo "Unzip OK"
  exit 0
else
  echo "Error with Unzip" >&2
  exit 1
fi

