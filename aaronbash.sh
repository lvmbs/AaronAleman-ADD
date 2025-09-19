#!/bin/bash

#Función menu:
menu(){

   #Definicion del valor por defecto de la variable opcion
   opcion=1

   #Bucle del menu que termina al introducir 0 como input
   while [ $opcion -ne 0 ]; do
      #Presentación del menú
      echo "************************"
      echo "* 0. Salir             *" 
      echo "* 1. Bisiesto          *"
      echo "* 2. Configurar red    *" 
      echo "* 3. Adivina           *"
      echo "* 4. Buscar            *"
      echo "* 5. Contar            *"
      echo "* 6. Permiso octal     *"
      echo "* 7. Romano            *"
      echo "************************"
      echo ""
      #Recogida del input del usuario para determinar la opcion a ejecutar
      read -p "Elige una opción del menú: " opcion
      echo ""

      #Case de las opciones disponibles
      case $opcion in
  
         #OPCIÓN 0, vacía, terminación del programa
         0) ;;

   	 #OPCIÓN 1, devuelve si el año pasado al introducido es bisiesto
         1)
            #Recogida del input del usuario (para determinar el año)
            read -p "Introduce un año: " anyo
            #Decremento de la variable anyo
	    let anyo--
	    #Condicional que determina si es año bisiesto
            echo ""
      	    if [ $((anyo % 4)) -eq 0 ]; then
               echo "$anyo es un año bisiesto"
            else
               echo "$anyo no es un año bisiesto"
            fi
	    sleep 2
	    echo ""
         ;;

	 #OPCIÓN 2, Configura la red con los parametros recogidos del usuario
         2)
            #Recogida de los parametros de red
            read -p "Introduce una nueva IP: " ip
            read -p "Introduce la mascara: " masc
            read -p "Introduce la puerta de enlace: " gate
            read -p "Introduce la dirección DNS: " dns

	    #Sobrescribe el archivo de config. de red por una plantilla
	    #que llega a antes del primer cambio
            cat /etc/netplan/redconfig > /etc/netplan/01-network-manager-all.yaml
            
            #Introducción linea a linea de lo restante + los parametros recogidos
            echo "     - $ip/$masc" >> /etc/netplan/01-network-manager-all.yaml
            echo "    routes:" >> /etc/netplan/01-network-manager-all.yaml
            echo "     - to: default" >> /etc/netplan/01-network-manager-all.yaml
            echo "       via: $gate" >> /etc/netplan/01-network-manager-all.yaml
            echo "    nameservers:" >> /etc/netplan/01-network-manager-all.yaml
            echo "      addresses: [$dns]" >> /etc/netplan/01-network-manager-all.yaml
            
            #Aplicación de los cambios (Sin output)
	    netplan apply > /dev/null 2>&1
	    echo ""
            #Comando para esperar 5 segundos antes de mostrar la config. de red
	    sleep 5
            #Comando para mostrar la config. de red
            ip addr
	    sleep 2
            echo ""
         ;;

	 #OPCIÓN 3, Juego para adivinar un numero del 1 al 100
         3)
	    #Asigna un numero random a num
            num=$((RANDOM % 100 + 1))
	    #Bucle for que itera 5 veces (por 5 intentos)
	    for i in $(seq 1 5); do
	      #Definición de variable intentos para mostrar intentos restantes
	      let intentos=5-i
	      #Input del usuario para adivinar el numero
              read -p "Intenta adivinar el numero: " intento
	      #Condicional que muestra si el numero es mayor, menor o es el numero aleatorio
	      if [ $intento -eq $num ]; then
                 echo "Numero adivinado ($num)"
                 echo "(Numero de intentos realizados: $i)"
	         break
	      elif [ $intento -gt $num ]; then
	         echo "El numero introducido es MAYOR que el numero a adivinar"
	         echo "(Te quedan $intentos intentos)"
              elif [ $intento -lt $num ]; then
	         echo "El numero introducido es MENOR que el numero a adivinar"
                 echo "(Te quedan $intentos intentos)"
              fi
            done
	    #Si se acabaron los intentos el condicional mostrará que se acabaron y el numero a adivinar
            if [ $intento -ne $num ]; then
               echo "Se te acabaron los intentos. El numero a adivinar era: $num"
            fi
            sleep 2
            echo ""
         ;;

	 #OPCIÓN 4, Introduce el nombre de un fichero y muestra el directorio donde se encuentra
         4)
	    #Input del usuario
            read -p "Introduce el nombre de un fichero: " fichero
     	    
	    #Asigna a la variable ruta la ruta en donde se encuentra el fichero
	    ruta=$(find / -type f -name "$fichero")
         
	    #Condicional que muestra donde se encuentra el directorio en caso de que exista
	    if [ -f "$ruta" ]; then
               directorio=$(dirname $ruta)
               echo "El directorio donde se encuentra es $directorio"
	       #Muestra las vocales que contiene el fichero
               vocales=$(grep -o -i '[aeiou]' $fichero | wc -l)
	       echo "El fichero $fichero contiene $vocales vocales"
            #En caso de no existir el fichero, muestra un error
            else
	       echo "Error, no hay ningun fichero llamado $fichero"
            fi
            sleep 2
            echo ""
         ;;
      
	 #OPCIÓN 5, Introduce el nombre de un directorio y cuenta cuantos ficheros hay en el mismo
         5)
            #Input del usuario
            read -p "Introduce el nombre de un directorio: " directorio
            #Asigna a count el conteo de los ficheros que estan dentro del directorio especificado
            count=$(find "$directorio" -maxdepth 1 -type f | wc -l)
	    #Muestra cuantos ficheros hay en el directorio
	    echo "Hay $count ficheros en $directorio"
            sleep 2
	    echo ""
         ;;

	 #OPCIÓN 6, Introduce el nombre de un objeto
         6)
	    #Input del usuario
    	    read -p "Introduce el nombre/ruta del objeto: " objeto
	    #Asigna el valor octal de los permisos de un objeto a la variable permisos
            permisos=$(stat -c "%a" $objeto)
	    #Muestra los permisos en octal del objeto
            echo "Los permisos en octal del objeto $objeto son: $permisos"
            sleep 2
	    echo ""
         ;;

	 #OPCIÓN 7, Introduce un numero del 1 al 200 y muestra el numero en numero romano
         7)
	    #Input del usuario
	    read -p "Introduce un numero del 1 al 200: " num
            
	    #Condicional que acepta el numero si esta en el rango de 1 a 200, en caso de no estarlo, muestra error
	    if [[ $num -ge 1 && $num -le 200 ]]; then
	       #Reduce el numero introducido para separarlo en diferentes unidades
	       centenas=$((num / 100))
               let num=$((num % 100))
               cincuentas=$((num / 50))
               let num=$((num % 50))
               decenas=$((num / 10))
	       let num=$((num % 10))
               cincos=$((num / 5))
               let num=$((num % 5))
	  
	       #Cuenta cuantas centenas hay
	       case $centenas in
                0) romCent="" ;;
                1) romCent="C" ;;
                2) romCent="CC" ;;
               esac

	       #Cuenta cuantos 50s hay
               case $cincuentas in
                0) romCincoCen="" ;;
                1) romCincoCen="L" ;;
               esac
 
	       #Cuenta cuantas decenas hay
               case $decenas in
                0) romDec="" ;;
                1) romDec="X" ;;
                2) romDec="XX" ;;
                3) romDec="XXX" ;;
                4) romDec="XL" ;;
               esac

               #Cuenta cuantos 5s hay
               case $cincos in
                0) romCinco="" ;;
                1) romCinco="V" ;;
               esac

	       #Cuenta cuantas unidades hay
               case $num in
                0) romUni="" ;;
                1) romUni="I" ;;
                2) romUni="II" ;;
                3) romUni="III" ;;
                4) romUni="IV" ;;
               esac

	       #Crea el numero romano con las variables creadas con los cases 
               numeroRomano="${romCent}${romCincoCen}${romDec}${romCinco}${romUni}"

	       #Muestra el numero en numero romano
               echo "Número romano: $numeroRomano"
            else
               echo "Numero inválido. Introduce un número del 1 al 200"
	    fi
            sleep 2
   	    echo ""
         ;;
	         
         #OPCIÓN INVÁLIDA, Muestra que has introducido un numero invalido
         *)
            echo "El numero de opción introducido es inválido"
            echo ""
         ;;


      esac
   done
}

#Llamada de la función menu
menu

