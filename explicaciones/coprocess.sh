#!/bin/bash

source ../gui/formatos.sh

function contar(){
    for i in {1..10}
    do
        echo Voy por $i
        sleep 1
    done
}

echo Lanzo el contador 
coproc miproceso { contar; }
echo Lanzado el contador. PID: $miproceso_PID

lineas=0
while read -r salida
do
    let lineas+=1
    echo $salida
    [[ $lineas == 4 ]] && break
done <&${miproceso}

#kill -9 $miproceso_PID
#echo CRUJO EL PROCESO
echo ESPERO AL PROCESO
wait $miproceso_PID
echo PROCESO ACABADO

contar & 
contar & 
contar & 
wait && echo YA ACABO || echo ACABO CON ERRORES