#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Este script precisa ser executado como root."
    exit 1
fi

DISPOSITIVO="/dev/sda"
TAMANHO_PARTICAO="100M"
PONTO_DE_MONTAGEM="/mnt/Copia de Seguranca"
USUARIO_PROPRIETARIO="root"
GRUPO_PROPRIETARIO="root"


echo -e "n\np\n\n\n+${TAMANHO_PARTICAO}\nw" | fdisk "$DISPOSITIVO" > /dev/null 2>&1


NOVA_PARTICAO="${DISPOSITIVO}1"
echo "y" | mkfs.ext4 "$NOVA_PARTICAO" > /dev/null 2>&1

mkdir -p "$PONTO_DE_MONTAGEM" > /dev/null 2>&1

mount "$NOVA_PARTICAO" "$PONTO_DE_MONTAGEM" > /dev/null 2>&1


if [ -n "$USUARIO_PROPRIETARIO" ] && [ -n "$GRUPO_PROPRIETARIO" ]; then
    chown -R "$USUARIO_PROPRIETARIO:$GRUPO_PROPRIETARIO" "$PONTO_DE_MONTAGEM" > /dev/null 2>&1
fi

UUID=$(blkid -s UUID -o value "$NOVA_PARTICAO" 2>/dev/null)


echo "UUID=$UUID   $PONTO_DE_MONTAGEM   ext4   defaults   0   2" >> /etc/fstab > /dev/null 2>&1

exit 0

exit 0


