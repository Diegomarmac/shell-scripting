#!/bin/bash
# Recovery de mysql, parte 2 de backupT1.sh
figlet "Recovery SQL.sh"
# Varaibles de ingreso a mysql
USER=root
PASSWD=paricutin
HOST=localhost
# Primero vamos a revisar que haya sido ejecutado como root
if [[ "${UID}" -ne 0  ]]
then
    cowsay "Ejecutar como sudo o root"
    exit 1
fi
# Revisamos que existan las carpetas del backup
ls | grep backups > /dev/null

if [[ "${?}"  -ne 0 ]]
then
    cowsay "No se han encontrado backups"
    exit 1
fi

if [[ "$(ls backups/ | wc -l)" -lt 1 ]]
then
    cowsay "No se han encontrado backups"
    exit 1
fi

# que lea la fecha del backup
cowsay "Las fechas mostradas son las fechas de los backups, ingrese, en el mismo formato dado, la fecha de la que haremos recovery"
# Listamos los backups existentes para que el usuario lo meta como un input
ls backups/ | grep ....-..-..
read FECHABACKUP
# COMENTARIOS DE LA FUNCIONALIDAD ANTERIOR
# El usuario debe pasar como parametro la fecha del backup
# entonces, debemos leer el parametro
# asegurarnos que es solo un parametro
#if [[ "${#}" -ne 1  ]]
#then
#    cowsay "Solo puedo leer un parametro, si no me diste parametro, dame la fecha del backup en formato YYYY-MM-DD"
#    exit 1
#fi
# asegurarnos que el usuario introdujo bien el parametro
#FECHABACKUP="${1}"
echo "${FECHABACKUP}" | grep ....-..-.. > /dev/null
if [[ ${?} -ne 0  ]]
then
    cowsay "El parametro debe estar en formato YYYY-MM-DD"
    exit 1
fi
# Ahora deberemos asegurarnos que el existe algun backup con la fecha del formato
ls backups/ | grep "${FECHABACKUP}" > /dev/null
if [[ ${?} -ne 0  ]]
then
    cowsay "No se encuentra el backup solicitado"
    exit 1
fi
#CREAMOS UN LOG CON EL TIMESTAMP DE ARRANQUE DEL RECOVERY
ls backups/ | grep recoveryLog > /dev/null
if [[ ${?} -ne 0  ]]
then
    touch backups/recoveryLog
fi
echo "Se inicio el recovery de ${FECHABACKUP}, el recovery comenzo en $(date) " >> backups/recoveryLog
# como tarda necesito darle un mensaje al usuario pa que no se espante
cowsay "El recovery ha empezado, esto puede tardar varios minutos, cuando salga el tren habremos acabado"
# apagamos el binary logging de las inserciones que vamos a realizar
mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B -e "SET SQL_LOG_BIN = 0"

#Ahora vamos a descomprimir y a insertar en mysql
ls backups/"${FECHABACKUP}" > tmp
cat tmp | while read line
do
    DATABASE=$line
    gunzip -c backups/"${FECHABACKUP}"/"${DATABASE}" | mysql
done

# Marcamos la fecha y hora de finalizado el recovery
echo "Se termino el recovery de ${FECHABACKUP}. termino en $(date)  " >> backups/recoveryLog
# Encendemos el binary logging
mysql -u "${USER}" -p"${PASSWD}" -h "${HOST}" -N -B -e "SET SQL_LOG_BIN = 1"
# borramos tmp
rm tmp
# invocamos el tren
sl
