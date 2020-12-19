#!/bin/bash
# 
# VARIABLES PARA CONEXION AL DBMS
USER=root
PASSWD=paricutin
HOST=localhost
# Primero vamos a revisar que haya sido ejecutado como root
if [[ "${UID}" -ne 0  ]]
then
    cowsay "Ejecutar como sudo o root"
    exit 1
fi

cowsay "Cuando salga un tren habremos terminado el backup!"

# Vamos a crear un archivo con el nombre de las bases de datos que hay
mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B -e "SHOW DATABASES" > databasesNames

# Quitamos los schemas y la base de datos mysql
grep -v "_schema" databasesNames > temp && mv temp databasesNames
grep -v "mysql" databasesNames > temp && mv temp databasesNames

# Ahora que por cada database en el documento que creamos haga un dumpfile
cat databasesNames | while read line
do
    DATABASE=$line
    mysqldump -c -B $DATABASE | gzip -9 > $DATABASE-$(date +%F).sql.gz
done
# Revisamos si existen los directorios para el backup
ls | grep backups > /dev/null

if [[ "${?}"  -ne 0 ]]
then
    mkdir backups
fi

ls backups/ | grep "$(date +%F)" > /dev/null

if [[ "${?}"  -ne 0 ]]
then
    mkdir backups/"$(date +%F)"
fi

# Movemos los backups a un directorio
mv *.sql.gz ./backups/"$(date +%F)/"
# Borramos databasesNames
rm databasesNames
# espero 3 segundos para que pueda leer la vaca
sleep 3
# llamamos al tren
sl
