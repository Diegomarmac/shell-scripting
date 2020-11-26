#!/bin/bash
# Prueba 3 de script para monitorizacion del DBMS MYSQL

USER=root
PASSWD=paricutin
HOST=localhost

# Primero vamos a mandar a un archivo los nombres de las bases de datos que hay 
mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B  -e "SHOW DATABASES" > $(dirname ${0})/epsilonLog

# Realizamos un conteo de cuantas bases de datos hay
NUMERO_DE_DATABASES=$(cat epsilonLog | wc -l)

# Lee epsilonLog y por cada base de datos encontrada crea el query para mostrar las tablas de cada base
# El segundo while, conforme se agrega cada query, lo ejecuta y guarda el resultado en un lof con el nombre 
# de la base de datos
# El tercer while crea archivos con los nombres de las tablas, estos archivos solo contienen el numero de rows
cat epsilonLog | while read line
do
    DATABASE=$line

    TMPSQL="SHOW TABLES FROM $DATABASE;"
    echo ${TMPSQL} > lt2.sql

    cat lt2.sql | while read line
        do
            mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B  -e "SOURCE lt2.sql" > "${DATABASE}"Log
        done
    cat "${DATABASE}"Log | while read line
        do
            TABLE=$line
            mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B  -e "SELECT COUNT(*) FROM ${DATABASE}.${TABLE}" > "${TABLE}"TableLog
        done    
done
# SELECT count(*) FROM world.city
# En este punto, ya logramos obtener las bases de datos y las tablas
# tenemos un log con las tablas de cada base de datos
# y tengo un log con los nombres de las bases de datos
#ToDo: que al iniciar el script:
#   1 revise si los logs existen, si existen hacer un conteo de lineas tanto del archivo con las bases
#       como del archivo con las tablas
#   2. si no  existen que los cree
#   3. que al final haga un conteo de lineas y compare, en caso de tener los conteos iniciales
#       Si hay diferencia en datos, entonces que muestre en que LOG hay diferencia


# ESTO NO SIRVE !!!! TARDA MUCHO Y GENERA BLOQUEOS EN EL DBMS