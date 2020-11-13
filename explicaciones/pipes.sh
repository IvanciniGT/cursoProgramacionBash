#!/bin/bash

source ../gui/formatos.sh

function contar(){
    for i in {1..10}
    do
        echo Voy por $i
        sleep 1
    done
}

function filtrar(){
    contador=0
    while read -r linea
    do
        (( $contador % 2 == 0 )) && azul "$linea"
        let contador+=1
    done 
}

# El pipe ejecuta las dos funciones en paralelo...
# Conectando la salida estandar de la primera, a la entrada estandar de la segunda.
# y el read -r de la segunda que lee de la entrada estandar

#contar | filtrar

contador=0
ultimo_fallo=0

function filtrar_pings(){
    while read -r linea
    do
        if [[ "$linea" =~ Unreachable$ ]] #Destination Host Unreachable
        then
            printf $($1 $(rojo 'X'))
        else
          printf $( $1 $(verde '.'))
        fi
    done 
}


function contar_fallos(){
    hora_ultima_salida=0

    while read -r linea
    do
        if [[ "$linea" =~ from || "$linea" =~ Unreachable ]]
        then 
            hora=$(date +%s)
            
            if [[ "$linea" =~ Unreachable$ ]] #Destination Host Unreachable
            then
                let contador+=1
                ultimo_fallo=$(date)
            fi
            
            if (( $hora_ultima_salida + 5 < $hora ))
            then
                hora_ultima_salida=$hora
    #            echo "ultima_salida=$hora_ultima_salida" > informe.pings
                echo "numero_de_fallos_$1=$contador" >> informe.pings
            fi
            
            echo "$linea"
        fi
    done 
}


(ping -i 1 -c 20 172.17.0.2 | contar_fallos A | filtrar_pings fondo_azul) & # Sincronización. No me llega el valor hasta que lo de dentro termine
(ping -i 1 -c 20 172.17.0.3 | contar_fallos B | filtrar_pings fondo_amarillo) & # Sincronización. No me llega el valor hasta que lo de dentro termine

wait
echo SALIENDO DEL PROGRAMA
#echo
#echo Número de fallos: $contador
#echo Último fallo: $ultimo_fallo