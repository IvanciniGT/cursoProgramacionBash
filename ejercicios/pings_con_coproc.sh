#!/bin/bash

source ../gui/formatos.sh

function filtrar_pings(){
    while read -r linea
    do
        if [[ "$linea" =~ Unreachable$ ]] #Destination Host Unreachable
        then
            echo 'X' #$($1 $(rojo 'X'))
        else
            echo '.' #$($1 $(verde '.'))
        fi
    done 
}

function contar_fallos(){
    hora_ultima_salida=0
    contador=0
    while read -r linea
    do
        if [[ "$linea" =~ from || "$linea" =~ Unreachable ]]
        then 
            hora=$(date +%s)
            
            if [[ "$linea" =~ Unreachable$ ]] #Destination Host Unreachable
            then
                contador=$(( $contador+1 ))
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

#(ping -i 1 172.17.0.2 | contar_fallos A | filtrar_pings fondo_azul >> ./fichero_tiempo_real)>/dev/null 2>&1 & # Sincronización. No me llega el valor hasta que lo de dentro termine

function mostrar_informe(){
    local __fallos_servidor_1
    local __fallos_servidor_2
    
    while read -r linea
    do
        linea=${linea//numero_de_fallos_}
        case $linea in
            B=*)
                __fallos_servidor_2=${linea//B=}
            ;;
            A=*)
                __fallos_servidor_1=${linea//A=}
            ;;
        esac
        clear
        titulo Estadisticas
        
        echo Fallos servidor 1: $__fallos_servidor_1
        echo Fallos servidor 2: $__fallos_servidor_2
        
        titulo Datos en tiempo real
        cat "./fichero_tiempo_real"
        echo
        azul $(linea)
        echo "Pulse una tecla para parar"
    done
}

> informe.pings
> fichero_tiempo_real

coproc ping1 { ping -i 1 172.17.0.2; } # ping1_PID
coproc contar1 { contar_fallos A<&${ping1}; }
coproc filtrar1 { filtrar_pings<&${contar1}; }

coproc tail1 { tail -f informe.pings; }
mostrar_informe<&${tail1}

wait $informe1_PID
echo HOLA
#contar_fallos A | filtrar_pings fondo_azul >> ./fichero_tiempo_rea