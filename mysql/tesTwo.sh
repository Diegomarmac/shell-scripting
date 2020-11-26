#!/bin/bash
# Prueba 2 de script para monitorizacion del DBMS MYSQL

USER=root
PASSWD=paricutin
HOST=localhost

# Primero vamos a mandar a un archivo los nombres de las bases de datos que hay 
mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B  -e "SHOW DATABASES" > $(dirname ${0})/epsilonLog

# Realizamos un conteo de cuantas bases de datos hay
NUMERO_DE_DATABASES=$(cat epsilonLog | wc -l)

# Lee epsilonLog y por cada base de datos encontrada crea el query para mostrar las tablas
# de cada base de datos, y lo manda a lt1.sql
cat epsilonLog | while read line
do
    DATABASE=$line

    TMPSQL="SHOW TABLES FROM $DATABASE;"
    echo ${TMPSQL} >> lt1.sql
done

#Lee lt1.sql y ejecuta cada query creado
cat lt1.sql | while read line
do
    mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -e "${line}"
done

# Problemas con este codigo: el archivop lt1.sql se sobreescribe cada que se ejecuta
# lo que con un uso constante terminara creando un lt1.sql enorme
# posible solucion, que lo elimine 
# otro detalle, en el segundo while... es necesario ? no seria mas eficiente que se lea el archivo lt1.sql con un source?
# Aqui no estoy ocupando el NUMERO DE DATABASES pero sera de utlidad para comparar en caso de que se cree una base de datos nueva
