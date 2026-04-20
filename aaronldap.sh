#!/bin/bash

BASE="dc=aaron2025,dc=ldap"
ADMIN="cn=admin,$BASE"

menu() {
    echo "====== MENU LDAP ======"
    echo "1. Eliminar correo de usuario"
    echo "2. Modificar correo de usuario"
    echo "3. Buscar usuarios"
    echo "4. Salir"
    echo "========================"
}

pedir_dn() {
    read -p "Introduce CN del usuario: " USER
    read -p "OU (Alumnado/Profesorado): " OU
    DN="cn=$USER,ou=$OU,$BASE"
}

eliminar_correo() {
    pedir_dn

    cat <<EOF > borrar.ldif
dn: $DN
changetype: modify
delete: mail
EOF

    ldapmodify -x -D "$ADMIN" -W -f borrar.ldif
}

modificar_correo() {
    pedir_dn
    read -p "Nuevo correo: " MAIL

    cat <<EOF > modificar.ldif
dn: $DN
changetype: modify
replace: mail
mail: $MAIL
EOF

    ldapmodify -x -D "$ADMIN" -W -f modificar.ldif
}

buscar() {
    echo "1. Buscar usuario concreto"
    echo "2. Listar todos"
    read -p "Elige opción: " OP

    if [ "$OP" == "1" ]; then
        read -p "Introduce CN: " USER
        ldapsearch -x -LLL -b "$BASE" "(cn=$USER)" cn mail
    else
        ldapsearch -x -LLL -b "$BASE" "(objectClass=inetOrgPerson)" cn mail
    fi
}

while true; do
    menu
    read -p "Selecciona opción: " OPCION

    case $OPCION in
        1) eliminar_correo ;;
        2) modificar_correo ;;
        3) buscar ;;
        4) exit ;;
        *) echo "Opción inválida" ;;
    esac
done
