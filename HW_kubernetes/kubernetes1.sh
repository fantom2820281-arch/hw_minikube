#!/bin/bash

# Проверяем количество переданных аргументов
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <имя_виртуальной_машины>"
    echo "Пример: $0 ansible1"
    exit 1
fi

# Получаем имя ВМ из аргумента
VM_NAME="$1"

set -e

create-vm() {
    local  # Объявляем локальные переменные
        ZONE="ru-central1-b" \
        SUBNET="default-ru-central1-b" \
        SSH_KEY_PATH="$HOME/.ssh/ssh-key-1763193011987.pub"
    
    # Создаем ВМ с указанными параметрами
    yc compute instance create \
        --name "$VM_NAME" \
        --hostname "$VM_NAME" \
        --zone "$ZONE" \
        --network-interface subnet-name="$SUBNET",nat-ip-version=ipv4 \
        --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts \
        --memory 4GB \
        --cores 2 \
        --ssh-key "$SSH_KEY_PATH"
}

# Вызываем функцию создания ВМ
create-vm