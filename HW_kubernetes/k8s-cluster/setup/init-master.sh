#!/bin/bash
# Инициализируем кластер
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Настройка kubectl для пользователя
mkdir -p $HOME/.kub
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Вывод команды для подключения воркеров
echo "=== Команда для воркеров ==="
kubeadm token create --print-join-command
