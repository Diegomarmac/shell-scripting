#!/bin/bash
# Prueba 4 de script para monitorizacion del DBMS MYSQL

# VARIABLE DE LA RUTA DEL SERVER
SRVROUTE=/srv/http/index.html

# Variable del PATH y su export
PATH=$(env | grep PATH)
export PATH

# Copiamos el log de MYSQL a un log temporal quitando los saltos de linea en blanco
grep . ~/.mysql_history > ./liquidlog

# Limpiamos el archivo index del server
true > /srv/http/index.html

# Creamos los archivos temporales
touch newlog
touch soliduslog

# Revisamos si el demonio de mysql está corriendo
# PARA CENTOS USAR : service mysqld status | grep running > /dev/null en lugar de la linea de abajo
systemctl is-active --quiet mysqld
if [[ ${?} -ne 0 ]] 
then
        date >> "${SRVROUTE}"
        echo "<h1>El servicio MYSQL está detenido</h1>" >> "${SRVROUTE}"

fi

# Quitamos del log temporal todos los select, exit, show, use, desc
# Los quitamos ya que estas instrucciones no modifican alguna base de datos o tabla
cat liquidlog | while read line
do
    LINEA=$line

    if ! [[ $(echo $LINEA | grep "select") ]] 
    then
        if ! [[ $(echo $LINEA | grep "SELECT") ]]
        then 
            if ! [[ $(echo $LINEA | grep "EXIT") ]]
            then
                if ! [[ $(echo $LINEA | grep "exit") ]]
                then
                    if ! [[ $(echo $LINEA | grep "DESC") ]]
                    then
                        if ! [[ $(echo $LINEA | grep "desc") ]]
                        then
                            if ! [[ $(echo $LINEA | grep "USE") ]]
                            then
                                if ! [[ $(echo $LINEA | grep "use") ]]
                                then
                                    if ! [[ $(echo $LINEA | grep "show") ]]
                                    then
                                        if ! [[ $(echo $LINEA | grep "SHOW") ]]
                                        then
                                            echo $LINEA >> newlog
                                            # Mandamos los logs que nos interesan a un archivo llamado newLog
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi    
        fi
    fi
done

if [[ -f oldlog ]]
then
    WCOFNEW=$(cat newlog | wc -l)
    WCOFOLD=$(cat oldlog | wc -l)
    
    if [[ WCOFOLD -eq WCOFNEW ]]
    then
        echo "<h1> $(date) Sin Cambios </h1>" >> "${SRVROUTE}"

    elif [[ WCOFOLD -gt WCOFNEW ]]
    then
        echo "$(date) El historial ha sido modificado" 
        # SI OLD ES MAYOR QUIERE DECIR QUE EL HISTORIAL DE MYSQL HA SIDO MODIFICADO...ALERTA!!!!
    else
        NUMOFNEWLINES=$(expr $WCOFNEW - $WCOFOLD)
        # añadimos las modificaciones al log central, este log central NO SE BORRA
        # el log BIGLOG contendrá todo el historial de detecciones

        echo "Modificaciones detectadas el: $(date)" >> biglog
        cat newlog | tail -n ${NUMOFNEWLINES} >> biglog
        # Creamos un archivo temporal llamado solidus log,  el cual contiene lo que se va mandar al server 

        echo "<h1>Se ha detectado cambios en el DMBS</h1>" >> soliduslog
        echo " <h2> $(date) </h2>" >> soliduslog
        cat newlog | tail -n ${NUMOFNEWLINES} >> soliduslog
        
        # En el while mandamos cada linea de SOLIDUS al server
        # se le agrega la etiqueta <p> al pasarlo, para que sea legible

        cat soliduslog | while read line
        do
    
            TMPHTML="<p> $line </p>"
            echo ${TMPHTML} >> "${SRVROUTE}"
        done

        # Reescribimos OldLog Con el COntenido de NewLog
        cat newlog > oldlog

    fi

else
    cp newlog oldlog
    echo " <h1> El monitoreo post log ha empezado con exito </h1>" >> "${SRVROUTE}"
fi

# Borramos los logs temporales
rm newlog
rm soliduslog